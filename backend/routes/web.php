<?php

use App\Http\Controllers\Admin\ActivityLogController;
use App\Http\Controllers\Admin\AnalyticsController;
use App\Http\Controllers\Admin\Auth\LoginController;
use App\Http\Controllers\Admin\DashboardController;
use App\Http\Controllers\Admin\OrderController;
use App\Http\Controllers\Admin\PhotoGalleryController;
use App\Http\Controllers\Admin\ProductController;
use App\Http\Controllers\Admin\RfidBindController;
use App\Http\Controllers\Admin\RfidScanLogController;
use App\Http\Controllers\Admin\StaffController;
use App\Http\Controllers\Admin\VisitorController;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return redirect()->route('admin.login');
});

Route::prefix('admin')->name('admin.')->group(function () {
    Route::middleware('guest:admin')->group(function () {
        Route::get('/login', [LoginController::class, 'show'])->name('login');
        Route::post('/login', [LoginController::class, 'store'])->name('login.store');
    });

    Route::post('/logout', [LoginController::class, 'destroy'])
        ->middleware('auth:admin')
        ->name('logout');

    // Shared staff area: admin + superadmin
    Route::middleware(['auth:admin', 'staff', 'role:admin,superadmin'])->group(function () {
        Route::get('/', DashboardController::class)->name('dashboard');

        Route::get('/visitors', [VisitorController::class, 'index'])->name('visitors.index');
        Route::get('/visitors/create', [VisitorController::class, 'create'])->name('visitors.create');
        Route::post('/visitors', [VisitorController::class, 'store'])->name('visitors.store');
        Route::get('/visitors/{visitor}/edit', [VisitorController::class, 'edit'])->name('visitors.edit');
        Route::put('/visitors/{visitor}', [VisitorController::class, 'update'])->name('visitors.update');
        Route::delete('/visitors/{visitor}', [VisitorController::class, 'destroy'])->name('visitors.destroy');

        Route::get('/rfid/bind', [RfidBindController::class, 'create'])->name('rfid.bind');
        Route::post('/rfid/bind', [RfidBindController::class, 'store'])->name('rfid.bind.store');

        Route::get('/rfid/scans', [RfidScanLogController::class, 'index'])->name('rfid.scans');

        Route::get('/gallery', [PhotoGalleryController::class, 'index'])->name('gallery.index');
        Route::get('/gallery/{verification}', [PhotoGalleryController::class, 'show'])->name('gallery.show');

        // Store (mobile e-commerce ops) — skeleton
        Route::get('/products', [ProductController::class, 'index'])->name('products.index');
        Route::get('/orders', [OrderController::class, 'index'])->name('orders.index');
    });

    // Superadmin-only
    Route::middleware(['auth:admin', 'staff', 'role:superadmin'])->group(function () {
        Route::get('/staff', [StaffController::class, 'index'])->name('staff.index');
        Route::get('/staff/create', [StaffController::class, 'create'])->name('staff.create');
        Route::post('/staff', [StaffController::class, 'store'])->name('staff.store');
        Route::get('/staff/{staff}/edit', [StaffController::class, 'edit'])->name('staff.edit');
        Route::put('/staff/{staff}', [StaffController::class, 'update'])->name('staff.update');
        Route::delete('/staff/{staff}', [StaffController::class, 'destroy'])->name('staff.destroy');

        Route::get('/analytics', AnalyticsController::class)->name('analytics');
        Route::get('/activity', [ActivityLogController::class, 'index'])->name('activity.index');
    });
});
