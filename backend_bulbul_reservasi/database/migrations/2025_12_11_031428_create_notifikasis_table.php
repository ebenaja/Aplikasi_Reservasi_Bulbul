<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('notifikasis', function (Blueprint $table) {
            $table->id();

            // Relasi ke User (Nullable: Bisa null jika broadcast promo ke semua)
            $tabled4d->foreignId('user_id')
                ->nullable()
                ->constrained('users')
                ->cascadeOnDelete();

            // Relasi ke Reservasi (Nullable: Hanya terisi jika tipe transaksi)
            $table->foreignId('reservasi_id')
                ->nullable()
                ->constrained('reservasis')
                ->cascadeOnDelete();

            $table->string('judul');
            $table->text('pesan');
            $table->string('tipe')->default('info'); // promo, transaksi, info
            $table->boolean('is_read')->default(false); // Tandai sudah dibaca

            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('notifikasis');
    }
};
