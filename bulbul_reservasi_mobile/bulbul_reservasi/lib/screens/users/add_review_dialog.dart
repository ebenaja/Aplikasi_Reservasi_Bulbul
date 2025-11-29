import 'package:flutter/material.dart';
import 'package:bulbul_reservasi/services/ulasan_service.dart';

class AddReviewDialog extends StatefulWidget {
  final int fasilitasId;
  const AddReviewDialog({super.key, required this.fasilitasId});

  @override
  State<AddReviewDialog> createState() => _AddReviewDialogState();
}

class _AddReviewDialogState extends State<AddReviewDialog> {
  final UlasanService _ulasanService = UlasanService();
  final TextEditingController _komentarCtrl = TextEditingController();
  final Color mainColor = const Color(0xFF50C2C9);
  
  int _selectedRating = 5;
  bool _isLoading = false;

  void _submit() async {
    setState(() => _isLoading = true);
    bool success = await _ulasanService.kirimUlasan(widget.fasilitasId, _selectedRating, _komentarCtrl.text);
    setState(() => _isLoading = false);

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Ulasan terkirim!"), backgroundColor: Colors.green));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal mengirim ulasan."), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Center(child: Text("Beri Ulasan", style: TextStyle(fontWeight: FontWeight.bold))),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Seberapa puas Anda?", style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () => setState(() => _selectedRating = index + 1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Icon(
                    index < _selectedRating ? Icons.star_rounded : Icons.star_border_rounded,
                    color: Colors.amber,
                    size: 36,
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: 20),
          TextField(
            controller: _komentarCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "Ceritakan pengalaman Anda...",
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              contentPadding: EdgeInsets.all(15)
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text("Batal", style: TextStyle(color: Colors.grey))),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: mainColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          onPressed: _isLoading ? null : _submit,
          child: _isLoading ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text("Kirim Ulasan", style: TextStyle(color: Colors.white)),
        )
      ],
    );
  }
}