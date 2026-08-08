<?php

namespace App\Services;

use App\Contracts\Repositories\AddressRepositoryInterface;
use App\Exceptions\DomainException;
use App\Models\Address;
use App\Models\User;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Support\Facades\DB;

class AddressService
{
    public function __construct(private readonly AddressRepositoryInterface $addresses)
    {
    }

    public function list(User $user): Collection
    {
        return $this->addresses->forUser($user);
    }

    public function store(User $user, array $data): Address
    {
        return DB::transaction(function () use ($user, $data) {
            if (! empty($data['is_default'])) {
                $this->addresses->clearDefault($user);
            }

            /** @var Address $address */
            $address = $this->addresses->create(array_merge($data, ['user_id' => $user->id]));

            return $address;
        });
    }

    public function update(User $user, int $id, array $data): Address
    {
        /** @var Address $address */
        $address = $this->addresses->findOrFail($id);
        $this->assertOwned($user, $address);

        return DB::transaction(function () use ($user, $address, $data) {
            if (! empty($data['is_default'])) {
                $this->addresses->clearDefault($user);
            }

            return $this->addresses->update($address, $data);
        });
    }

    public function delete(User $user, int $id): void
    {
        /** @var Address $address */
        $address = $this->addresses->findOrFail($id);
        $this->assertOwned($user, $address);
        $this->addresses->delete($address);
    }

    private function assertOwned(User $user, Address $address): void
    {
        if ($address->user_id !== $user->id) {
            throw new DomainException('Address not found.', 404, 'address_not_found');
        }
    }
}