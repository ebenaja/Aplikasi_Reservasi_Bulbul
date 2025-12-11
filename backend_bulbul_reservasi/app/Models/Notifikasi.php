<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Notifikasi extends Model
{
    use HasFactory;

    protected $table = 'notifikasis';

    protected $fillable = [
        'user_id',
        'reservasi_id',
        'judul',
        'pesan',
        'tipe',
        'is_read'
    ];

    // Relasi ke Reservasi (Optional)
    public function reservasi()
    {
        return $this->belongsTo(Reservasi::class, 'reservasi_id');
    }

    // Relasi ke User (Optional)
    public function user()
    {
        return $this->belongsTo(User::class, 'user_id');
    }
}
