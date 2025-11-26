<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class RolesSeeder extends Seeder
{
    public function run(): void
    {
        $roles = [
            [
                'name' => 'admin',
                'description' => 'Administrator'
            ],
            [
                'name' => 'customer',
                'description' => 'Customer biasa'
            ],
        ];

        foreach ($roles as $role) {
            DB::table('roles')->updateOrInsert(
                ['name' => $role['name']],
                ['description' => $role['description']]
            );
        }
    }
}
