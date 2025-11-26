<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('pembayarans', function (Blueprint $table) {
            $table->id();

            $table->foreignId('reservasi_id')
                ->unique()
                ->constrained('reservasis')
                ->cascadeOnDelete();

            $table->string('bukti', 255)->nullable();
            $table->string('status', 20)->default('menunggu'); // menunggu / valid / ditolak

            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('pembayarans');
    }
};
