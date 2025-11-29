<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('reservasis', function (Blueprint $table) {
            $table->id();

            $table->foreignId('user_id')
                ->constrained('users')
                ->cascadeOnDelete();

            $table->foreignId('fasilitas_id')
                ->constrained('fasilitas')
                ->cascadeOnDelete();

            $table->date('tanggal_sewa');
            $table->time('jam_mulai'); // Format: 14:30:00

            $table->integer('durasi');
            $table->decimal('total_harga', 12, 2);
            $table->string('status', 20)->default('pending');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('reservasis');
    }
};
