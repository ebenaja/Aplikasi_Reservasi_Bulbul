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
    Schema::table('reservasis', function (Blueprint $table) {
        // Menambahkan kolom jam_mulai (TIME) setelah tanggal_sewa
        $table->time('jam_mulai')->default('08:00:00')->after('tanggal_sewa');
    });
}

public function down(): void
{
    Schema::table('reservasis', function (Blueprint $table) {
        $table->dropColumn('jam_mulai');
    });
}
};
