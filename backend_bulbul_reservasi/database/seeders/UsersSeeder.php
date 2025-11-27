<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class UsersSeeder extends Seeder
{
    public function run(): void
    {
        // ambil id role admin dari kolom "name"
        $adminRoleId = DB::table('roles')
            ->where('name', 'admin')
            ->value('id');

        // buat admin default
        DB::table('users')->updateOrInsert(
            ['email' => 'admin@bulbul.com'],
            [
                'role_id' => $adminRoleId,
                'nama' => 'Administrator BulBul',
                'password' => Hash::make('admin123'),
                'created_at' => now(),
            ]
        );
    }
}
