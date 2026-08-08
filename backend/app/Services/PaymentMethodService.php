<?php

namespace App\Services;

use App\Contracts\Repositories\PaymentMethodRepositoryInterface;
use App\Exceptions\DomainException;
use App\Models\PaymentMethod;
use App\Models\User;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Support\Facades\DB;

class PaymentMethodService
{
    public function __construct(private readonly PaymentMethodRepositoryInterface $paymentMethods)
    {
    }

    public function list(User $user): Collection
    {
        return $this->paymentMethods->forUser($user);
    }

    public function store(User $user, array $data): PaymentMethod
    {
        return DB::transaction(function () use ($user, $data) {
            if (! empty($data['is_default'])) {
                $this->paymentMethods->clearDefault($user);
            }

            /** @var PaymentMethod $method */
            $method = $this->paymentMethods->create(array_merge($data, ['user_id' => $user->id]));

            return $method;
        });
    }

    public function delete(User $user, int $id): void
    {
        /** @var PaymentMethod $method */
        $method = $this->paymentMethods->findOrFail($id);

        if ($method->user_id !== $user->id) {
            throw new DomainException('Payment method not found.', 404, 'payment_method_not_found');
        }

        $this->paymentMethods->delete($method);
    }
}