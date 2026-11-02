<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('rfid_members', function (Blueprint $table) {
            $table->decimal('balance', 12, 2)->default(0)->after('is_active');
        });

        $cards = DB::table('rfid_members')->whereNotNull('user_id')->get(['id', 'user_id']);
        foreach ($cards as $card) {
            $balance = DB::table('members')->where('user_id', $card->user_id)->value('balance');
            if ($balance !== null) {
                DB::table('rfid_members')->where('id', $card->id)->update(['balance' => $balance]);
            }
        }

        $this->makeUserOptional('kiosk_check_ins');
        $this->makeUserOptional('kiosk_presences');
        $this->makeUserOptional('wallet_ledgers');

        Schema::table('wallet_ledgers', function (Blueprint $table) {
            $table->foreignId('rfid_member_id')
                ->nullable()
                ->after('user_id')
                ->constrained('rfid_members')
                ->nullOnDelete();
        });
    }

    public function down(): void
    {
        Schema::table('wallet_ledgers', function (Blueprint $table) {
            $table->dropConstrainedForeignId('rfid_member_id');
        });

        Schema::table('rfid_members', function (Blueprint $table) {
            $table->dropColumn('balance');
        });
    }

    private function makeUserOptional(string $table): void
    {
        Schema::table($table, function (Blueprint $blueprint) {
            $blueprint->dropForeign(['user_id']);
        });

        Schema::table($table, function (Blueprint $blueprint) {
            $blueprint->unsignedBigInteger('user_id')->nullable()->change();
        });

        Schema::table($table, function (Blueprint $blueprint) {
            $blueprint->foreign('user_id')->references('id')->on('users')->nullOnDelete();
        });
    }
};
