<?php

namespace App\Repositories;

use App\Contracts\Repositories\RfidRepositoryInterface;
use App\Models\RfidMember;
use App\Models\RfidVerification;

class RfidRepository extends BaseRepository implements RfidRepositoryInterface
{
    public function __construct(RfidMember $model)
    {
        parent::__construct($model);
    }

    public function findActiveMember(string $memberId): ?RfidMember
    {
        return $this->query()
            ->where('is_active', true)
            ->where(function ($q) use ($memberId) {
                $q->where('member_code', $memberId)
                    ->orWhere('rfid_uid', $memberId);
            })
            ->first();
    }

    public function findMemberByCode(string $memberId): ?RfidMember
    {
        return $this->query()
            ->where(function ($q) use ($memberId) {
                $q->where('member_code', $memberId)
                    ->orWhere('rfid_uid', $memberId);
            })
            ->first();
    }

    public function createVerification(array $attributes): RfidVerification
    {
        return RfidVerification::query()->create($attributes);
    }
}