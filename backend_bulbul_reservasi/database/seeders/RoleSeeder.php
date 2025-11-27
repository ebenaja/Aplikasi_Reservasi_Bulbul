<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class RoleSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
{
    \DB::table('roles')->insert([
        ['id' => 1, 'nama_role' => 'admin'],
        ['id' => 2, 'nama_role' => 'user'],
    ]);
}
}
