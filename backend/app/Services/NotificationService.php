<?php

namespace App\Services;

use App\Contracts\Repositories\NotificationRepositoryInterface;
use App\Exceptions\DomainException;
use App\Models\AppNotification;
use App\Models\User;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

class NotificationService
{
    public function __construct(private readonly NotificationRepositoryInterface $notifications)
    {
    }

    public function list(User $user, int $perPage = 20): LengthAwarePaginator
    {
        return $this->notifications->forUser($user, $perPage);
    }

    public function markRead(User $user, int $id): AppNotification
    {
        /** @var AppNotification $notification */
        $notification = $this->notifications->findOrFail($id);

        if ($notification->user_id !== $user->id) {
            throw new DomainException('Notification not found.', 404, 'notification_not_found');
        }

        return $this->notifications->update($notification, ['is_read' => true]);
    }

    public function markAllRead(User $user): int
    {
        return $this->notifications->markAllRead($user);
    }
}