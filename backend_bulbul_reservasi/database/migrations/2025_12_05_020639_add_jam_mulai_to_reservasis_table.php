<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // Cek dulu apakah kolom 'jam_mulai' SUDAH ADA di tabel 'reservasis'
        if (!Schema::hasColumn('reservasis', 'jam_mulai')) {

            Schema::table('reservasis', function (Blueprint $table) {
                // Jika belum ada, baru tambahkan
                $table->time('jam_mulai')->default('08:00:00')->after('tanggal_sewa');
            });

        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Cek dulu apakah kolomnya ada sebelum menghapus
        if (Schema::hasColumn('reservasis', 'jam_mulai')) {
            Schema::table('reservasis', function (Blueprint $table) {
                $table->dropColumn('jam_mulai');
            });
        }
    }
};
