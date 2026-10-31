<?php

namespace Tests\Feature;

use App\Enums\UserRole;
use App\Models\KioskCheckIn;
use App\Models\KioskLocation;
use App\Models\KioskPointLedger;
use App\Models\KioskPresence;
use App\Models\Member;
use App\Models\RfidMember;
use App\Models\User;
use App\Models\WalletLedger;
use App\Models\UserFaceEnrollment;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class KioskVisitEnrollmentTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        Storage::fake('local');
        config(['kiosk.checkin_points' => 10, 'kiosk.scan_cooldown_seconds' => 60]);

        if (! KioskLocation::query()->where('is_active', true)->exists()) {
            KioskLocation::query()->create([
                'code' => 'MAIN',
                'name' => 'Main',
                'is_active' => true,
            ]);
        }
    }

    public function test_face_enrollment_stores_three_poses(): void
    {
        [$user, $rfid] = $this->seedBoundMember();

        $response = $this->post('/api/v1/kiosk/face-enrollment', [
            'rfid_uid' => $rfid->rfid_uid,
            'front' => UploadedFile::fake()->image('front.jpg'),
            'right' => UploadedFile::fake()->image('right.jpg'),
            'left' => UploadedFile::fake()->image('left.jpg'),
        ]);

        $response->assertCreated()->assertJsonPath('success', true);
        $this->assertSame(3, UserFaceEnrollment::query()->where('user_id', $user->id)->count());
    }

    public function test_visit_awards_points_without_photo(): void
    {
        [$user, $rfid] = $this->seedBoundMember();

        $response = $this->postJson('/api/v1/kiosk/visit', [
            'rfid_uid' => $rfid->rfid_uid,
        ]);

        $response->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.granted', true)
            ->assertJsonPath('data.points.earned', 10)
            ->assertJsonPath('data.wallet.charged', 10000);

        $this->assertSame(1, KioskCheckIn::query()->where('user_id', $user->id)->where('status', 'success')->count());
        $this->assertSame(1, KioskPointLedger::query()->where('user_id', $user->id)->count());
        $this->assertSame(1, WalletLedger::query()->where('user_id', $user->id)->count());
        $this->assertSame(10, (int) Member::query()->where('user_id', $user->id)->value('points'));
        $this->assertSame('40000.00', Member::query()->where('user_id', $user->id)->value('balance'));
    }

    public function test_visit_with_photo_stores_experience_capture(): void
    {
        [$user, $rfid] = $this->seedBoundMember();

        $response = $this->post('/api/v1/kiosk/visit', [
            'rfid_uid' => $rfid->rfid_uid,
            'photo' => UploadedFile::fake()->image('visit.jpg'),
        ]);

        $response->assertOk()->assertJsonPath('data.has_photo', true);
        $checkIn = KioskCheckIn::query()->where('user_id', $user->id)->first();
        $this->assertNotNull($checkIn?->presence_id);
        $this->assertNotNull(KioskPresence::query()->find($checkIn->presence_id)?->photo_path);
    }

    public function test_visit_denies_when_balance_is_below_fare(): void
    {
        [$user, $rfid] = $this->seedBoundMember(balance: 0);

        $response = $this->postJson('/api/v1/kiosk/visit', [
            'rfid_uid' => $rfid->rfid_uid,
        ]);

        $response->assertOk()
            ->assertJsonPath('data.granted', false)
            ->assertJsonPath('data.result_code', 'INSUFFICIENT_BALANCE')
            ->assertJsonPath('data.points.earned', 0);

        $this->assertSame(0, (int) Member::query()->where('user_id', $user->id)->value('points'));
        $this->assertSame('0.00', Member::query()->where('user_id', $user->id)->value('balance'));
        $this->assertSame(0, WalletLedger::query()->where('user_id', $user->id)->count());
        $this->assertSame(1, KioskCheckIn::query()->where('status', 'denied')->count());
    }

    public function test_duplicate_scan_within_cooldown_does_not_create_visit(): void
    {
        [$user, $rfid] = $this->seedBoundMember();

        $this->postJson('/api/v1/kiosk/visit', ['rfid_uid' => $rfid->rfid_uid])->assertOk();
        $second = $this->postJson('/api/v1/kiosk/visit', ['rfid_uid' => $rfid->rfid_uid]);

        $second->assertOk()
            ->assertJsonPath('data.duplicate', true)
            ->assertJsonPath('data.points.earned', 0);

        $this->assertSame(1, KioskCheckIn::query()->where('user_id', $user->id)->where('status', 'success')->count());
        $this->assertSame(10, (int) Member::query()->where('user_id', $user->id)->value('points'));
        $this->assertSame('40000.00', Member::query()->where('user_id', $user->id)->value('balance'));
    }

    public function test_invalid_rfid_visit_fails(): void
    {
        $response = $this->postJson('/api/v1/kiosk/visit', [
            'rfid_uid' => 'UNKNOWN-CARD-999',
        ]);

        $response->assertStatus(422);
        $this->assertSame(0, KioskCheckIn::query()->count());
    }

    /**
     * @return array{0:User,1:RfidMember}
     */
    private function seedBoundMember(float $balance = 50000): array
    {
        $user = User::query()->create([
            'name' => 'Muhammad',
            'email' => 'muhammad@example.com',
            'password' => 'password',
            'role' => UserRole::Visitor,
            'onboarding_completed_at' => now(),
        ]);

        Member::query()->create([
            'user_id' => $user->id,
            'display_name' => $user->name,
            'points' => 0,
            'balance' => $balance,
        ]);

        $rfid = RfidMember::query()->create([
            'user_id' => $user->id,
            'member_code' => 'KUTUKU-001',
            'rfid_uid' => '0182120545',
            'is_active' => true,
        ]);

        return [$user, $rfid];
    }
}
