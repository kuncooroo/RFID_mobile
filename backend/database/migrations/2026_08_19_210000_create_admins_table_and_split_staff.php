<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('admins', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('email')->unique();
            $table->string('phone')->nullable()->unique();
            $table->string('password');
            $table->string('role', 32);
            $table->string('avatar_path')->nullable();
            $table->rememberToken();
            $table->timestamps();
            $table->softDeletes();
            $table->index('role');
        });

        $staffRoles = ['admin', 'superadmin'];

        $staff = DB::table('users')
            ->whereIn('role', $staffRoles)
            ->whereNull('deleted_at')
            ->get();

        foreach ($staff as $row) {
            if ($row->email === null || $row->email === '') {
                continue;
            }

            DB::table('admins')->insert([
                'id' => $row->id,
                'name' => $row->name,
                'email' => $row->email,
                'phone' => $row->phone,
                'password' => $row->password,
                'role' => $row->role,
                'avatar_path' => $row->avatar_path ?? null,
                'remember_token' => $row->remember_token,
                'created_at' => $row->created_at,
                'updated_at' => $row->updated_at,
                'deleted_at' => null,
            ]);
        }

        $maxId = (int) (DB::table('admins')->max('id') ?? 0);
        if ($maxId > 0 && Schema::getConnection()->getDriverName() === 'mysql') {
            DB::statement('ALTER TABLE admins AUTO_INCREMENT = '.($maxId + 1));
        }

        Schema::table('admin_activity_logs', function (Blueprint $table) {
            $table->foreignId('admin_id')->nullable()->after('id')->constrained('admins')->nullOnDelete();
        });

        if (Schema::hasColumn('admin_activity_logs', 'user_id')) {
            $adminIds = DB::table('admins')->pluck('id');
            DB::table('admin_activity_logs')
                ->whereIn('user_id', $adminIds)
                ->update(['admin_id' => DB::raw('user_id')]);

            Schema::table('admin_activity_logs', function (Blueprint $table) {
                $table->dropConstrainedForeignId('user_id');
            });
        }

        $staffIds = $staff->pluck('id')->all();
        if ($staffIds !== []) {
            $safeToRemove = [];
            foreach ($staffIds as $userId) {
                $hasMemberProfile = DB::table('members')->where('user_id', $userId)->exists();
                $hasRfid = DB::table('rfid_members')->where('user_id', $userId)->exists();
                $hasOrders = Schema::hasTable('orders')
                    && DB::table('orders')->where('user_id', $userId)->exists();
                $hasCart = Schema::hasTable('carts')
                    && DB::table('carts')->where('user_id', $userId)->exists();
                $hasSettings = Schema::hasTable('user_settings')
                    && DB::table('user_settings')->where('user_id', $userId)->exists();

                if ($hasMemberProfile || $hasRfid || $hasOrders || $hasCart || $hasSettings) {
                    DB::table('users')->where('id', $userId)->update(['role' => 'visitor']);
                    continue;
                }

                $safeToRemove[] = $userId;
            }

            if ($safeToRemove !== []) {
                DB::table('users')->whereIn('id', $safeToRemove)->delete();
            }
        }

        if (! $this->indexExists('rfid_verifications', 'rfid_verifications_created_at_index')) {
            Schema::table('rfid_verifications', function (Blueprint $table) {
                $table->index('created_at');
                $table->index('status');
            });
        }
    }

    public function down(): void
    {
        if (Schema::hasColumn('admin_activity_logs', 'admin_id') && ! Schema::hasColumn('admin_activity_logs', 'user_id')) {
            Schema::table('admin_activity_logs', function (Blueprint $table) {
                $table->foreignId('user_id')->nullable()->after('id')->constrained()->nullOnDelete();
            });

            DB::table('admin_activity_logs')
                ->whereNotNull('admin_id')
                ->update(['user_id' => DB::raw('admin_id')]);

            Schema::table('admin_activity_logs', function (Blueprint $table) {
                $table->dropConstrainedForeignId('admin_id');
            });
        }

        Schema::dropIfExists('admins');
    }

    private function indexExists(string $table, string $index): bool
    {
        $connection = Schema::getConnection();
        if ($connection->getDriverName() !== 'mysql') {
            return false;
        }

        $database = $connection->getDatabaseName();
        $result = $connection->selectOne(
            'SELECT COUNT(*) AS c FROM information_schema.statistics WHERE table_schema = ? AND table_name = ? AND index_name = ?',
            [$database, $table, $index],
        );

        return (int) ($result->c ?? 0) > 0;
    }
};
