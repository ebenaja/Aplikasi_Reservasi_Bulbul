<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Fasilitas extends Model
{
    use HasFactory;

    protected $table = 'fasilitas';

    protected $fillable = [
        'nama_fasilitas',
        'deskripsi',
        'harga',
        'stok',
        'status',
        'foto',
    ];

    // --- TAMBAHKAN INI ---
    public function ulasan()
    {
        // Relasi: Satu Fasilitas punya banyak Ulasan
        return $this->hasMany(Ulasan::class, 'fasilitas_id');
    }
}
