<?php

namespace App\Contracts\Repositories;

use App\Models\RfidMember;

interface RfidRepositoryInterface extends BaseRepositoryInterface
{
    public function findActiveMember(string $memberId): ?RfidMember;
}