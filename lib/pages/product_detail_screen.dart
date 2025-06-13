import 'package:flutter/material.dart';
import '../controller/product_controller.dart';
import '../data/product_api.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Product currentProduct;
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    currentProduct = widget.product;
    loadProductDetails();
  }

  void loadProductDetails() async {
    setState(() => isLoading = true);
    try {
      currentProduct = await getProductDetails(widget.product.id);
      errorMessage = null;
    } catch (e) {
      errorMessage = e.toString();
      if (e.toString().contains('Unauthorized')) _handleUnauthorized();
    }
    setState(() => isLoading = false);
  }

  void _handleUnauthorized() => showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      title: Text('Phiên đăng nhập hết hạn'),
      content: Text('Vui lòng đăng nhập lại'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pushReplacementNamed(context, '/'),
          child: Text('Đăng nhập lại'),
        ),
      ],
    ),
  );

  void _showEditDialog() {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: currentProduct.name);
    final priceCtrl = TextEditingController(
      text: currentProduct.price.toString(),
    );
    final quantityCtrl = TextEditingController(
      text: currentProduct.quantity.toString(),
    );
    final coverCtrl = TextEditingController(text: currentProduct.cover);
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Chỉnh sửa sản phẩm'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  _inputField(nameCtrl, 'Tên sản phẩm'),
                  _inputField(priceCtrl, 'Giá (vnđ)', isNumber: true),
                  _inputField(quantityCtrl, 'Số lượng', isNumber: true),
                  _inputField(coverCtrl, 'URL hình ảnh'),
                  if (isSubmitting)
                    Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: CircularProgressIndicator(),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting ? null : () => Navigator.pop(context),
              child: Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      if (formKey.currentState!.validate()) {
                        setDialogState(() => isSubmitting = true);
                        try {
                          final updatedProduct = Product(
                            id: currentProduct.id,
                            name: nameCtrl.text.trim(),
                            price: int.parse(priceCtrl.text),
                            quantity: int.parse(quantityCtrl.text),
                            cover: coverCtrl.text.trim(),
                          );
                          final result = await updateProductInApi(
                            updatedProduct,
                          );
                          setState(() => currentProduct = result);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Cập nhật sản phẩm thành công'),
                            ),
                          );
                        } catch (e) {
                          setDialogState(() => isSubmitting = false);
                          if (e.toString().contains('Unauthorized')) {
                            Navigator.pop(context);
                            _handleUnauthorized();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Lỗi cập nhật: $e')),
                            );
                          }
                        }
                      }
                    },
              child: Text('Cập nhật'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteProduct() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Xác nhận xóa'),
        content: Text(
          'Bạn có chắc muốn xóa sản phẩm "${currentProduct.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      setState(() => isLoading = true);
      try {
        await deleteProductFromApi(currentProduct.id);
        Navigator.pop(context, true);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Xóa sản phẩm thành công')));
      } catch (e) {
        setState(() => isLoading = false);
        if (e.toString().contains('Unauthorized'))
          _handleUnauthorized();
        else
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Lỗi xóa sản phẩm: $e')));
      }
    }
  }

  Widget _inputField(
    TextEditingController ctrl,
    String label, {
    bool isNumber = false,
  }) => TextFormField(
    controller: ctrl,
    decoration: InputDecoration(labelText: label),
    keyboardType: isNumber ? TextInputType.number : null,
    validator: (v) =>
        v == null || v.isEmpty || (isNumber && int.tryParse(v) == null)
        ? 'Bắt buộc${isNumber ? ' & phải là số' : ''}'
        : null,
  );

  Widget _buildInfoRow(String label, String value, {bool isUrl = false}) =>
      Padding(
        padding: EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 120,
              child: Text(
                '$label:',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: isUrl
                    ? TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      )
                    : null,
              ),
            ),
          ],
        ),
      );

  Widget _buildProductImage() => Container(
    height: 300,
    width: double.infinity,
    child: Image.network(
      currentProduct.cover,
      fit: BoxFit.cover,
      loadingBuilder: (_, child, loading) =>
          loading == null ? child : Center(child: CircularProgressIndicator()),
      errorBuilder: (_, __, ___) =>
          Center(child: Icon(Icons.broken_image, size: 64, color: Colors.grey)),
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(currentProduct.name),
      backgroundColor: Colors.orange,
      actions: [
        IconButton(
          icon: Icon(Icons.edit),
          onPressed: isLoading ? null : _showEditDialog,
        ),
        IconButton(
          icon: Icon(Icons.delete),
          onPressed: isLoading ? null : _deleteProduct,
        ),
      ],
    ),
    body: isLoading
        ? Center(child: CircularProgressIndicator())
        : errorMessage != null
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64),
                SizedBox(height: 8),
                Text(
                  'Có lỗi xảy ra',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(errorMessage!, textAlign: TextAlign.center),
                ElevatedButton(
                  onPressed: loadProductDetails,
                  child: Text('Thử lại'),
                ),
              ],
            ),
          )
        : SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProductImage(),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentProduct.name,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.attach_money),
                          Text('${currentProduct.price} đ'),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.inventory),
                          Text(' Số lượng: ${currentProduct.quantity}'),
                        ],
                      ),
                      SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Thông tin chi tiết',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              _buildInfoRow(
                                'ID sản phẩm',
                                currentProduct.id.toString(),
                              ),
                              _buildInfoRow(
                                'Tên sản phẩm',
                                currentProduct.name,
                              ),
                              _buildInfoRow(
                                'Giá bán',
                                '${currentProduct.price} đ',
                              ),
                              _buildInfoRow(
                                'Số lượng tồn kho',
                                '${currentProduct.quantity}',
                              ),
                              _buildInfoRow(
                                'URL hình ảnh',
                                currentProduct.cover,
                                isUrl: true,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
    bottomNavigationBar: !isLoading
        ? BottomAppBar(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _showEditDialog,
                      icon: Icon(Icons.edit),
                      label: Text('Chỉnh sửa'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _deleteProduct,
                      icon: Icon(Icons.delete),
                      label: Text('Xóa'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        : null,
  );
}
