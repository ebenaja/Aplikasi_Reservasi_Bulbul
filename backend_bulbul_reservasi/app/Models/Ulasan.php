<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Ulasan extends Model
{
    use HasFactory;

    protected $table = 'ulasan'; // Nama tabel singular

    protected $fillable = [
        'user_id',
        'fasilitas_id',
        'rating',
        'komentar',
    ];

    // Relasi: Ulasan milik User (penulis)
    public function user()
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    // Relasi: Ulasan milik Fasilitas
    public function fasilitas()
    {
        return $this->belongsTo(Fasilitas::class, 'fasilitas_id');
    }
}
