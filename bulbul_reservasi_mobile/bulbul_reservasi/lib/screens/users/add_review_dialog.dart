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
  int _selectedRating = 5; // Default bintang 5
  bool _isLoading = false;
  final Color mainColor = Color(0xFF50C2C9);

  void _submit() async {
    setState(() => _isLoading = true);
    
    bool success = await _ulasanService.kirimUlasan(
      widget.fasilitasId, 
      _selectedRating, 
      _komentarCtrl.text
    );

    setState(() => _isLoading = false);

    if (success) {
      Navigator.pop(context); // Tutup dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terima kasih atas ulasan Anda!"), backgroundColor: Colors.green)
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal mengirim ulasan."), backgroundColor: Colors.red)
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text("Beri Ulasan", style: TextStyle(fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Bagaimana pengalaman Anda?", style: TextStyle(color: Colors.grey)),
          SizedBox(height: 15),
          
          // Bintang Rating Manual
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                onPressed: () {
                  setState(() {
                    _selectedRating = index + 1;
                  });
                },
                icon: Icon(
                  index < _selectedRating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 32,
                ),
              );
            }),
          ),
          
          SizedBox(height: 15),
          
          TextField(
            controller: _komentarCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "Tulis komentar Anda disini...",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: EdgeInsets.all(10)
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text("Batal")),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: mainColor),
          onPressed: _isLoading ? null : _submit,
          child: _isLoading 
            ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
            : Text("Kirim", style: TextStyle(color: Colors.white)),
        )
      ],
    );
  }
}