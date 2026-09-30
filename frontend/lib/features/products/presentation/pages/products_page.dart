import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/network/http_client.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/calotex_sidebar.dart';
import '../../../../shared/widgets/calotex_top_bar.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  List<Map<String, dynamic>> _products = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final response = await sl<HttpClient>().dio.get('/products');
      final data = response.data['data'];
      setState(() {
        _products = (data is List)
            ? data.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList()
            : [];
        _error = null;
      });
    } on DioException catch (error) {
      setState(() => _error = error.response?.data['message']?.toString() ?? 'Could not load products');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save(Map<String, dynamic>? product) async {
    final fields = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _ProductDialog(product: product),
    );
    if (fields == null) return;
    try {
      final client = sl<HttpClient>().dio;
      Response<dynamic> response;
      final form = FormData.fromMap({
        ...fields,
        if (fields['assembly_pdf'] is PlatformFile)
          'assembly_pdf': MultipartFile.fromBytes(
            (fields['assembly_pdf'] as PlatformFile).bytes!,
            filename: (fields['assembly_pdf'] as PlatformFile).name,
            contentType: MediaType('application', 'pdf'),
          ),
        if (fields['product_photo'] is PlatformFile)
          'product_photo': MultipartFile.fromBytes(
            (fields['product_photo'] as PlatformFile).bytes!,
            filename: (fields['product_photo'] as PlatformFile).name,
            contentType: MediaType('image', 'png'),
          ),
      });
      if (product == null) {
        response = await client.post('/products', data: form);
      } else {
        response = await client.patch('/products/${product['id']}', data: form);
      }
      final saved = response.data is Map ? response.data['data'] : null;
      final photoUploaded = fields['product_photo'] is PlatformFile &&
          saved is Map &&
          saved['product_photo'] is String &&
          (saved['product_photo'] as String).isNotEmpty;
      final assemblyUploaded = fields['assembly_pdf'] is PlatformFile &&
          saved is Map &&
          saved['assembly_pdf'] is String &&
          (saved['assembly_pdf'] as String).isNotEmpty;
      await _load();
      if (!mounted) return;
      final hasAssembly = fields['assembly_pdf'] is PlatformFile;
      final hasPhoto = fields['product_photo'] is PlatformFile;
      if ((hasPhoto && !photoUploaded) || (hasAssembly && !assemblyUploaded)) {
        throw StateError('The product was saved, but one or more file URLs were not returned.');
      }
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: AppTheme.accentGreen),
              SizedBox(width: 10),
              Text('Upload successful'),
            ],
          ),
          content: Text(
            product == null
                ? 'The product was created successfully.'
                : 'The product was updated successfully.'
            '${hasAssembly || hasPhoto ? '\n\n' : ''}'
            '${hasAssembly ? 'Assembly PDF uploaded successfully.\n' : ''}'
            '${hasPhoto ? 'Product PNG photo uploaded successfully.' : ''}',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Done'),
            ),
          ],
        ),
      );
    } on DioException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.response?.data['message']?.toString() ?? 'Could not save product')),
        );
      }
    }
  }

  Future<void> _delete(Map<String, dynamic> product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete product?'),
        content: Text('Delete ${product['product_code']}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: AppTheme.accentRed),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await sl<HttpClient>().dio.delete('/products/${product['id']}');
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    final user = auth is Authenticated ? auth.user : null;
    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CalotexSidebar(
            activeRoute: '/products',
            userRole: user?.role ?? '',
            onNavItemTap: (route) {
              if (route == '/logout') {
                context.read<AuthBloc>().add(const LogoutRequested());
                Navigator.pushReplacementNamed(context, '/login');
              } else if (route != '/products') {
                Navigator.pushReplacementNamed(context, route);
              }
            },
          ),
          Expanded(
            child: Column(
              children: [
                CalotexTopBar(
                  userName: user?.firstName ?? 'User',
                  userRole: user?.role ?? '',
                  avatar: user?.avatar,
                  onProfileTap: () => Navigator.pushNamed(context, '/profile'),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacingLg),
                    child: _loading
                        ? const Center(child: CircularProgressIndicator(color: AppTheme.accentCyan))
                        : _error != null
                            ? Center(child: Text(_error!, style: const TextStyle(color: AppTheme.accentRed)))
                            : _content(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _content() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Products', style: AppTheme.heading1),
            FilledButton.icon(
              onPressed: () => _save(null),
              icon: const Icon(Icons.add),
              label: const Text('Add product'),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingLg),
        Expanded(
          child: Card(
            color: AppTheme.bgElevated,
            child: _products.isEmpty
                ? const Center(child: Text('No products yet', style: TextStyle(color: AppTheme.textMuted)))
                : ListView.separated(
                    padding: const EdgeInsets.all(AppTheme.spacingMd),
                    itemCount: _products.length,
                    separatorBuilder: (_, __) => const Divider(color: AppTheme.divider),
                    itemBuilder: (_, index) {
                      final product = _products[index];
                      return ListTile(
                        title: Text('${product['product_code']} - ${product['name']}'),
                        subtitle: Text(
                          'Assembly: ${product['assembly_pdf'] != null ? 'PDF attached' : 'None'}  |  Client: ${product['client_name']}  |  Category: ${product['category']}',
                        ),
                        trailing: Wrap(
                          children: [
                            IconButton(onPressed: () => _save(product), icon: const Icon(Icons.edit_outlined)),
                            IconButton(
                              onPressed: () => _delete(product),
                              icon: const Icon(Icons.delete_outline, color: AppTheme.accentRed),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}

class _ProductDialog extends StatefulWidget {
  final Map<String, dynamic>? product;
  const _ProductDialog({this.product});

  @override
  State<_ProductDialog> createState() => _ProductDialogState();
}

class _ProductDialogState extends State<_ProductDialog> {
  late final Map<String, TextEditingController> _controllers = {
    'product_code': TextEditingController(text: widget.product?['product_code']?.toString() ?? ''),
    'name': TextEditingController(text: widget.product?['name']?.toString() ?? ''),
    'client_name': TextEditingController(text: widget.product?['client_name']?.toString() ?? ''),
    'category': TextEditingController(text: widget.product?['category']?.toString() ?? ''),
  };
  PlatformFile? _assemblyPdf;
  PlatformFile? _productPhoto;

  Future<void> _pick(String field) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [field == 'assembly_pdf' ? 'pdf' : 'png'],
      withData: true,
    );
    final file = result?.files.single;
    if (file == null || file.bytes == null) return;
    setState(() {
      if (field == 'assembly_pdf') {
        _assemblyPdf = file;
      } else {
        _productPhoto = file;
      }
    });
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.product == null ? 'Add product' : 'Edit product'),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            children: [
              ..._controllers.entries.map((entry) {
                final label = entry.key == 'product_code'
                    ? 'Product ID (W1234-5678)'
                    : entry.key.replaceAll('_', ' ');
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextField(
                    controller: entry.value,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(labelText: label),
                  ),
                );
              }),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => _pick('assembly_pdf'),
                icon: const Icon(Icons.picture_as_pdf_outlined),
                label: Text(_assemblyPdf?.name ?? 'Choose assembly PDF'),
              ),
              OutlinedButton.icon(
                onPressed: () => _pick('product_photo'),
                icon: const Icon(Icons.image_outlined),
                label: Text(_productPhoto?.name ?? 'Choose product PNG photo'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () => Navigator.pop(
            context,
            {
              ..._controllers.map((key, controller) => MapEntry(key, controller.text.trim())),
              'assembly_pdf': _assemblyPdf,
              'product_photo': _productPhoto,
            },
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
