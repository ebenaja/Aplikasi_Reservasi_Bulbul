<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Role extends Model
{
    use HasFactory;

    protected $table = 'roles';

    // Pastikan fillable sesuai dengan kolom database Anda
    protected $fillable = [
        'nama_role', // atau 'name' tergantung migrasi Anda
    ];
}
