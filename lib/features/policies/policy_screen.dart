import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/app_providers.dart';
import '../../../shared/widgets/premium_app_bar.dart';
import '../../../shared/widgets/premium_text_field.dart';
import '../../../core/theme/bookstore_tokens.dart';

class PolicyScreen extends ConsumerWidget {
  final String id;
  const PolicyScreen({super.key, required this.id});
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: PremiumAppBar(
      title: id == 'privacy' ? 'Privacy Policy' : 'Terms of Service',
    ),
    body: !['privacy', 'terms'].contains(id)
        ? const Center(child: Text('Policy not found'))
        : ref
              .watch(policyProvider(id))
              .when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) =>
                    Center(child: Text('Unable to load this policy: $e')),
                data: (policy) => policy == null
                    ? const Center(
                        child: Text('This policy has not been published yet.'),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 760),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  policy['title'] as String,
                                  style: BookstoreTokens.display(fontSize: 30),
                                ),
                                const SizedBox(height: 8),
                                Text('Version ${policy['version']}'),
                                const SizedBox(height: 24),
                                SelectableText(
                                  policy['content'] as String,
                                  style: BookstoreTokens.body(
                                    fontSize: 15,
                                    height: 1.7,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
              ),
  );
}

class PolicyEditorScreen extends ConsumerStatefulWidget {
  const PolicyEditorScreen({super.key});
  @override
  ConsumerState<PolicyEditorScreen> createState() => _PolicyEditorScreenState();
}

class _PolicyEditorScreenState extends ConsumerState<PolicyEditorScreen> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController(),
      _content = TextEditingController(),
      _version = TextEditingController();
  String _id = 'terms';
  bool _loading = true, _saving = false;
  String? _error;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final doc = await ref
          .read(firebaseFirestoreProvider)
          .collection('policies')
          .doc(_id)
          .get();
      if (!mounted) return;
      _title.text = doc.data()?['title'] as String? ?? '';
      _content.text = doc.data()?['content'] as String? ?? '';
      _version.text = doc.data()?['version'] as String? ?? '';
    } catch (e) {
      _error = 'Unable to load policy: $e';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _content.dispose();
    _version.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(firebaseFirestoreProvider)
          .collection('policies')
          .doc(_id)
          .set({
            'title': _title.text.trim(),
            'content': _content.text.trim(),
            'version': _version.text.trim(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Policy published')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Unable to publish policy: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const PremiumAppBar(title: 'Terms & Privacy'),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        DropdownButtonFormField<String>(
          initialValue: _id,
          items: const [
            DropdownMenuItem(value: 'terms', child: Text('Terms of Service')),
            DropdownMenuItem(value: 'privacy', child: Text('Privacy Policy')),
          ],
          onChanged: _loading || _saving
              ? null
              : (v) {
                  _id = v!;
                  _load();
                },
        ),
        const SizedBox(height: 20),
        if (_loading)
          const Center(child: CircularProgressIndicator())
        else if (_error != null)
          Column(
            children: [
              Text(_error!),
              TextButton(onPressed: _load, child: const Text('Retry')),
            ],
          )
        else
          Form(
            key: _form,
            child: Column(
              children: [
                PremiumTextField(
                  controller: _title,
                  label: 'Title',
                  validator: (v) =>
                      v == null || v.trim().isEmpty || v.trim().length > 120
                      ? 'Enter a title of up to 120 characters'
                      : null,
                ),
                const SizedBox(height: 16),
                PremiumTextField(
                  controller: _version,
                  label: 'Version',
                  validator: (v) =>
                      v == null || v.trim().isEmpty || v.trim().length > 80
                      ? 'Enter a version of up to 80 characters'
                      : null,
                ),
                const SizedBox(height: 16),
                PremiumTextField(
                  controller: _content,
                  label: 'Policy Text',
                  maxLines: 18,
                  validator: (v) =>
                      v == null || v.trim().isEmpty || v.length > 50000
                      ? 'Enter policy text of up to 50,000 characters'
                      : null,
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: Text(_saving ? 'Publishing…' : 'Publish Policy'),
                ),
              ],
            ),
          ),
      ],
    ),
  );
}
