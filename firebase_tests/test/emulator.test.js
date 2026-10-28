const {test,before,after}=require('node:test');
const assert=require('node:assert/strict');
const fs=require('node:fs');
const {initializeTestEnvironment,assertFails,assertSucceeds}=require('@firebase/rules-unit-testing');
const {doc,setDoc,getDoc,updateDoc,collection,getDocs,query,where,runTransaction,serverTimestamp,Timestamp,orderBy,limit,startAfter,connectFirestoreEmulator,getFirestore,deleteDoc,FieldPath,increment,deleteField}=require('firebase/firestore');
let env,alice,bob,admin;
const book={id:'title',title:'Integration test title',author:'Test author',genre:'Testing',price:19.99,stockQuantity:10,coverUrl:'',description:'',publishedDate:'2026-01-01'};
async function seed(path,data){await env.withSecurityRulesDisabled(async c=>setDoc(doc(c.firestore(),path),data));}
async function prepare(uid){await seed(`users/${uid}`,{fullName:uid,email:`${uid}@example.test`,role:'customer',membershipTier:'Member',avatarUrl:null});await seed(`users/${uid}/addresses/home`,{label:'Home',recipientName:uid,phone:'123',street:'Test street',city:'Test city',state:'Test',postalCode:'123',country:'Test',isDefault:true});await seed(`users/${uid}/paymentMethods/cod`,{type:'cod',title:'Cash on delivery',subtitle:'Pay on arrival',isDefault:true});}
async function checkout(db,uid,key,ids=['title'],options={}){
 return runTransaction(db,async tx=>{
  const ref=doc(db,'orders',key),old=await tx.get(ref);if(old.exists())return key;
  const address=await tx.get(doc(db,`users/${uid}/addresses/home`)),payment=await tx.get(doc(db,`users/${uid}/paymentMethods/cod`));
  const settings=(await tx.get(doc(db,'settings/store'))).data();
  const books=[];for(const id of ids)books.push(await tx.get(doc(db,'books',id)));
  const items=books.map(b=>({bookId:b.id,quantity:1,book:options.forgePrice?{...b.data(),price:0}:b.data()}));
  if(items.some(i=>i.book.stockQuantity<1))throw new Error('Insufficient stock');
  const sub=items.reduce((s,i)=>s+Math.round(i.book.price*100),0),off=options.promo?Math.round(sub*0.1):0;
  if(options.promo)await tx.get(doc(db,'promotions','TEN'));
  const ship=sub>=Math.round(settings.freeShippingThreshold*100)?0:Math.round(settings.shippingFee*100),tax=Math.round((sub-off)*settings.taxRate);
  tx.set(ref,{userId:uid,orderNumber:key,items,itemIndex:Object.fromEntries(items.map((item,i)=>[item.bookId,i])),subtotal:sub/100,discount:off/100,shipping:ship/100,tax:tax/100,total:options.forgeTotal?0:(sub-off+ship+tax)/100,addressId:'home',shippingAddress:address.data(),paymentMethodId:'cod',paymentMethod:payment.data(),promoCode:options.promo?'TEN':null,status:'placed',paymentStatus:'unpaid',createdAt:serverTimestamp(),statusHistory:{placed:serverTimestamp()}});
  if(!options.omitStock)books.forEach(b=>tx.update(b.ref,{stockQuantity:b.data().stockQuantity-1,lastOrderId:key}));
  return key;
 });
}
async function review(db,uid,rating){return runTransaction(db,async tx=>{
 const br=doc(db,'books/title'),rr=doc(db,`books/title/reviews/${uid}`),b=await tx.get(br),old=await tx.get(rr),u=await tx.get(doc(db,`users/${uid}`));
 const counts={...b.data().ratingCounts};if(old.exists())counts[old.data().rating]=(counts[old.data().rating]||1)-1;counts[rating]=(counts[rating]||0)+1;
 const total=Object.values(counts).reduce((s,n)=>s+n,0),sum=Object.entries(counts).reduce((s,[r,n])=>s+Number(r)*n,0);
 tx.set(rr,{userId:uid,userName:u.data().fullName,userAvatar:'',rating,content:'A review written in an isolated test.',createdAt:serverTimestamp(),...(!old.exists()?{helpfulCount:0,helpfulBy:{}}:{})},{merge:true});
 tx.update(br,{ratingScore:sum/total,reviewTotal:total,rating:sum/total,reviewCount:total,ratingCounts:counts,ratingBreakdown:Object.fromEntries([1,2,3,4,5].map(r=>[r,(counts[r]||0)/total]))});
});}
before(async()=>{if(!process.env.FIRESTORE_EMULATOR_HOST)throw new Error('Use firebase emulators:exec; these tests never run in production.');env=await initializeTestEnvironment({projectId:'demo-bookstore',firestore:{rules:fs.readFileSync('firestore.rules','utf8')}});await env.clearFirestore();alice=env.authenticatedContext('alice',{email:'alice@example.test'}).firestore();bob=env.authenticatedContext('bob',{email:'bob@example.test'}).firestore();admin=env.authenticatedContext('admin',{email:'admin@example.test'}).firestore();await prepare('alice');await prepare('bob');await seed('users/admin',{fullName:'Store admin',email:'admin@example.test',role:'admin',membershipTier:'Member'});await seed('books/title',book);await seed('settings/store',{freeShippingThreshold:50,shippingFee:5,taxRate:0.08});await seed('promotions/TEN',{active:true,type:'percent',amount:10});});
after(async()=>env?.cleanup());
test('public catalog, private accounts, protected roles and aggregate fields',async()=>{await assertSucceeds(getDoc(doc(env.unauthenticatedContext().firestore(),'books/title')));await assertFails(getDoc(doc(bob,'users/alice/addresses/home')));await assertFails(updateDoc(doc(alice,'users/alice'),{role:'admin'}));await assertFails(updateDoc(doc(admin,'users/admin'),{role:'customer'}));await assertSucceeds(updateDoc(doc(admin,'users/bob'),{role:'admin'}));await assertSucceeds(updateDoc(doc(admin,'users/bob'),{role:'customer'}));await assertFails(updateDoc(doc(alice,'books/title'),{rating:5}));await assertFails(setDoc(doc(alice,'users/alice/cart/title'),{bookId:'title',quantity:99}));});
test('checkout commits valid prices and stock once; rejects tampered totals and missing inventory write',async()=>{await assertFails(checkout(alice,'alice','forged',['title'],{forgeTotal:true}));await assertFails(checkout(alice,'alice','forged-price',['title'],{forgePrice:true}));await assertFails(checkout(alice,'alice','no-stock',['title'],{omitStock:true}));await assertSucceeds(checkout(alice,'alice','purchase'));const order=(await getDoc(doc(alice,'orders/purchase'))).data();assert.equal(order.total,26.59);assert.equal((await getDoc(doc(alice,'books/title'))).data().stockQuantity,9);await checkout(alice,'alice','purchase');assert.equal((await getDoc(doc(alice,'books/title'))).data().stockQuantity,9);await assertFails(getDoc(doc(bob,'orders/purchase')));await assertSucceeds(getDocs(query(collection(alice,'orders'),where('userId','==','alice'))));});
test('five-title checkout with promotion stays within security-rule access limits',async()=>{for(let i=0;i<5;i++)await seed('books/volume'+i,{...book,id:'volume'+i});await assertSucceeds(checkout(alice,'alice','five-titles',Array.from({length:5},(_,i)=>'volume'+i),{promo:true}));});
test('more than five titles are rejected as a complete atomic operation',async()=>{await seed('books/volume5',{...book,id:'volume5'});await assertFails(checkout(alice,'alice','too-many',Array.from({length:6},(_,i)=>'volume'+i)));});
test('duplicate titles cannot reserve stock once for two line items',async()=>{await assertFails(checkout(alice,'alice','duplicate',['title','title']));});
test('competing buyers cannot oversell the last copy',async()=>{await seed('books/last',{...book,id:'last',stockQuantity:1});const results=await Promise.allSettled([checkout(alice,'alice','race-a',['last']),checkout(bob,'bob','race-b',['last'])]);assert.equal(results.filter(r=>r.status==='fulfilled').length,1);assert.equal((await getDoc(doc(admin,'books/last'))).data().stockQuantity,0);});
test('reviews atomically maintain one rating per user and reject independent score edits',async()=>{await assertSucceeds(review(alice,'alice',5));await assertSucceeds(review(alice,'alice',3));const b=(await getDoc(doc(alice,'books/title'))).data();assert.equal(b.rating,3);assert.equal(b.reviewCount,1);await assertFails(updateDoc(doc(alice,'books/title/reviews/alice'),{rating:1,createdAt:serverTimestamp()}));await assertFails(review(alice,'alice',7));});
test('only administrators can progress order status or mark payment collected',async()=>{await assertFails(updateDoc(doc(alice,'orders/purchase'),{status:'delivered',paymentStatus:'paid',statusHistory:{placed:Timestamp.now(),delivered:serverTimestamp()}}));await assertSucceeds(runTransaction(admin,async tx=>{const ref=doc(admin,'orders/purchase'),o=await tx.get(ref);tx.update(ref,{status:'confirmed',paymentStatus:'unpaid',statusHistory:{...o.data().statusHistory,confirmed:serverTimestamp()}});}));await assertFails(updateDoc(doc(admin,'orders/purchase'),{total:0}));});

test('administrator cancellation restores inventory once and preserves the receipt',async()=>{
 async function cancel(){return runTransaction(admin,async tx=>{const ref=doc(admin,'orders/purchase'),o=await tx.get(ref);if(o.data().status==='cancelled')return;const lines=o.data().items,books=[];for(const line of lines)books.push(await tx.get(doc(admin,'books',line.bookId)));books.forEach((b,i)=>tx.update(b.ref,{stockQuantity:b.data().stockQuantity+lines[i].quantity}));tx.update(ref,{status:'cancelled',paymentStatus:'unpaid',statusHistory:{...o.data().statusHistory,cancelled:serverTimestamp()}});});}
 await assertSucceeds(cancel());const stock=(await getDoc(doc(admin,'books/title'))).data().stockQuantity;await assertSucceeds(cancel());assert.equal((await getDoc(doc(admin,'books/title'))).data().stockQuantity,stock);assert.equal((await getDoc(doc(alice,'orders/purchase'))).data().total,26.59);
});
test('store configuration is protected and validates usable rates',async()=>{await assertFails(updateDoc(doc(alice,'settings/store'),{taxRate:0}));await assertFails(updateDoc(doc(admin,'settings/store'),{taxRate:-1}));await assertFails(updateDoc(doc(admin,'settings/store'),{taxRate:2}));await assertSucceeds(updateDoc(doc(admin,'settings/store'),{taxRate:0.08}));});
async function toggleHelpful(db,uid,reviewId='alice'){
 return runTransaction(db,async tx=>{
  const rr=doc(db,`books/title/reviews/${reviewId}`),r=await tx.get(rr),voters={...r.data().helpfulBy};
  tx.update(rr,new FieldPath('helpfulBy',uid),voters[uid]?deleteField():true,'helpfulCount',increment(voters[uid]?-1:1));
 });
}
test('helpful votes toggle atomically, reject self-votes and cannot forge counts',async()=>{
 if(!(await getDoc(doc(alice,'books/title/reviews/alice'))).exists())await review(alice,'alice',3);
 await assertSucceeds(toggleHelpful(bob,'bob'));assert.equal((await getDoc(doc(alice,'books/title/reviews/alice'))).data().helpfulCount,1);
 await assertFails(updateDoc(doc(bob,'books/title/reviews/alice'),{helpfulCount:99}));
 await assertFails(setDoc(doc(bob,'books/title/reviews/alice/helpful/admin'),{userId:'admin',createdAt:serverTimestamp()}));
 await assertFails(toggleHelpful(alice,'alice'));
 await assertSucceeds(toggleHelpful(bob,'bob'));assert.equal((await getDoc(doc(alice,'books/title/reviews/alice'))).data().helpfulCount,0);
 await Promise.all([toggleHelpful(bob,'bob'),toggleHelpful(admin,'admin')]);
 assert.equal((await getDoc(doc(alice,'books/title/reviews/alice'))).data().helpfulCount,2);
 await assertFails(updateDoc(doc(bob,'books/title/reviews/alice'),{helpfulBy:{bob:true,fake:true},helpfulCount:2}));
 await assertSucceeds(review(alice,'alice',4));
 assert.equal((await getDoc(doc(alice,'books/title/reviews/alice'))).data().helpfulCount,2);
 assert.equal((await getDoc(doc(alice,'books/title'))).data().ratingScore,4);
});
test('promotion management is admin-only and rejects invalid discounts',async()=>{
 const promotion={active:true,type:'percent',amount:15,minimumSubtotal:10};
 await assertFails(setDoc(doc(alice,'promotions/NEW'),promotion));
 await assertSucceeds(setDoc(doc(admin,'promotions/NEW'),promotion));
 await assertFails(updateDoc(doc(admin,'promotions/NEW'),{amount:101}));
 await assertFails(updateDoc(doc(admin,'promotions/NEW'),{amount:-1}));
 await assertSucceeds(updateDoc(doc(admin,'promotions/NEW'),{active:false,expiresAt:Timestamp.now()}));
});
test('policies are public and only administrators may publish server-timestamped versions',async()=>{
 const policy={title:'Test policy',content:'Isolated policy fixture.',version:'1',updatedAt:serverTimestamp()};
 await assertFails(setDoc(doc(alice,'policies/terms'),policy));
 await assertSucceeds(setDoc(doc(admin,'policies/terms'),policy));
 await assertSucceeds(getDoc(doc(env.unauthenticatedContext().firestore(),'policies/terms')));
 await assertFails(updateDoc(doc(admin,'policies/terms'),{content:''}));
});
test('image uploads enforce owner, size and administrator cover permissions',async()=>{
 const image={ownerId:'alice',purpose:'avatar',contentType:'image/png',data:'aGVsbG8=',createdAt:serverTimestamp()};
 await assertSucceeds(setDoc(doc(alice,'media/aaaaaaaaaaaaaaaaaaaa'),image));
 await assertSucceeds(getDoc(doc(env.unauthenticatedContext().firestore(),'media/aaaaaaaaaaaaaaaaaaaa')));
 await assertFails(setDoc(doc(bob,'media/bbbbbbbbbbbbbbbbbbbb'),image));
 await assertFails(setDoc(doc(alice,'media/cccccccccccccccccccc'),{...image,purpose:'cover'}));
 await assertFails(setDoc(doc(alice,'media/dddddddddddddddddddd'),{...image,data:'a'.repeat(600001)}));
 await assertSucceeds(setDoc(doc(admin,'media/eeeeeeeeeeeeeeeeeeee'),{...image,ownerId:'admin',purpose:'cover'}));
 await assertFails(updateDoc(doc(alice,'media/aaaaaaaaaaaaaaaaaaaa'),{data:'changed'}));
});
test('catalog metadata is public but cannot be changed by customers',async()=>{
 await assertFails(setDoc(doc(alice,'catalog/metadata'),{genres:['Fake']}));
 await assertSucceeds(setDoc(doc(admin,'catalog/metadata'),{genres:['Testing'],genreCounts:{Testing:1}}));
 await assertSucceeds(getDoc(doc(env.unauthenticatedContext().firestore(),'catalog/metadata')));
});

test('indexed catalog pagination returns every new unreviewed title once',async()=>{
 for(let i=0;i<30;i++)await setDoc(doc(admin,`books/paged-${String(i).padStart(2,'0')}`),{...book,id:`paged-${i}`,title:`Paged book ${i}`,ratingScore:0,reviewTotal:0,searchTokens:['paged']});
 const base=query(collection(alice,'books'),where('searchTokens','array-contains','paged'),orderBy('reviewTotal','desc'),orderBy('__name__','desc'));
 const first=await getDocs(query(base,limit(24))),second=await getDocs(query(base,startAfter(first.docs.at(-1)),limit(24)));
 assert.equal(first.size,24);assert.equal(second.size,6);assert.equal(new Set([...first.docs,...second.docs].map(d=>d.id)).size,30);
 await assertFails(updateDoc(doc(alice,'books/paged-00'),{ratingScore:5}));
 await assertFails(updateDoc(doc(admin,'books/paged-00'),{reviewTotal:500}));
});
test('real emulator authentication supports registration through delivery and account isolation',async()=>{
 if(!process.env.FIREBASE_AUTH_EMULATOR_HOST)throw new Error('Run both auth and firestore emulators.');
 const {initializeApp,deleteApp}=require('firebase/app');
 const {getAuth,connectAuthEmulator,createUserWithEmailAndPassword,signOut}=require('firebase/auth');
 const apps=[];
 async function account(name){const app=initializeApp({projectId:'demo-bookstore',apiKey:'emulator-only-key',appId:'emulator-only-app'},name);apps.push(app);const auth=getAuth(app);connectAuthEmulator(auth,'http://'+process.env.FIREBASE_AUTH_EMULATOR_HOST,{disableWarnings:true});const user=(await createUserWithEmailAndPassword(auth,`${name}@example.test`,'emulator-only-password')).user;const db=getFirestore(app);const [host,port]=process.env.FIRESTORE_EMULATOR_HOST.split(':');connectFirestoreEmulator(db,host,Number(port));return {auth,user,db};}
 try{
  const customer=await account('customer-'+Date.now()),owner=await account('owner-'+Date.now());
  await setDoc(doc(admin,'policies/privacy'),{title:'Privacy',content:'Test policy.',version:'1',updatedAt:serverTimestamp()});
  await setDoc(doc(customer.db,`users/${customer.user.uid}`),{fullName:'Integration customer',email:customer.user.email,role:'customer',membershipTier:'Member',memberSince:serverTimestamp(),phone:null,avatarUrl:null,policyAcceptance:{termsVersion:'1',privacyVersion:'1',acceptedAt:serverTimestamp()}});
  await env.withSecurityRulesDisabled(async c=>setDoc(doc(c.firestore(),`users/${owner.user.uid}`),{fullName:'Integration administrator',email:owner.user.email,role:'admin',membershipTier:'Member'}));
  await setDoc(doc(owner.db,'books/authenticated-purchase'),{...book,id:'authenticated-purchase',ratingScore:0,reviewTotal:0,searchTokens:['authenticated']});
  await setDoc(doc(customer.db,`users/${customer.user.uid}/cart/authenticated-purchase`),{bookId:'authenticated-purchase',quantity:1});
  await setDoc(doc(customer.db,`users/${customer.user.uid}/wishlist/authenticated-purchase`),{bookId:'authenticated-purchase'});
  await setDoc(doc(customer.db,`users/${customer.user.uid}/addresses/home`),{label:'Home',recipientName:'Integration customer',phone:'1234567890',street:'Integration street',city:'Test city',state:'Test',postalCode:'123',country:'Test',isDefault:true});
  await setDoc(doc(customer.db,`users/${customer.user.uid}/paymentMethods/cod`),{type:'cod',title:'Cash on delivery',subtitle:'Pay on arrival',isDefault:true});
  await checkout(customer.db,customer.user.uid,'authenticated-order',['authenticated-purchase']);
  await deleteDoc(doc(customer.db,`users/${customer.user.uid}/cart/authenticated-purchase`));
  for(const status of ['confirmed','processing','shipped','delivered'])await runTransaction(owner.db,async tx=>{const ref=doc(owner.db,'orders/authenticated-order'),order=await tx.get(ref);tx.update(ref,{status,paymentStatus:status==='delivered'?'paid':'unpaid',statusHistory:{...order.data().statusHistory,[status]:serverTimestamp()}});});
  const receipt=(await getDoc(doc(customer.db,'orders/authenticated-order'))).data();
  assert.equal(receipt.status,'delivered');assert.equal(receipt.paymentStatus,'paid');assert.equal(Object.keys(receipt.statusHistory).length,5);
  assert.equal((await getDoc(doc(customer.db,'books/authenticated-purchase'))).data().stockQuantity,9);
  assert.equal((await getDocs(collection(customer.db,`users/${customer.user.uid}/cart`))).size,0);
  await assertFails(getDoc(doc(bob,`users/${customer.user.uid}`)));
  await signOut(customer.auth);
  await assertFails(getDoc(doc(customer.db,'orders/authenticated-order')));
 }finally{await Promise.all(apps.map(app=>deleteApp(app)));}
});
