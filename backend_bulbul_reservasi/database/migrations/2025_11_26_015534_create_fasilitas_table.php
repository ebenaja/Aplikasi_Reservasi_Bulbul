<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
public function up(): void
    {
        Schema::create('fasilitas', function (Blueprint $table) {
            $table->id();
            $table->string('nama_fasilitas', 100);
            $table->text('deskripsi')->nullable();
            $table->decimal('harga', 12, 2);
            $table->integer('stok')->default(1);
            $table->string('status', 20)->default('tersedia'); // tersedia / disewa
            $table->string('foto', 255)->nullable(); // Menyimpan path/url foto
            $table->timestamps();
            $table->boolean('is_promo')->default(false);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('fasilitas');
    }
};
