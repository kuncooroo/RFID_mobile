<?php

use App\Http\Controllers\Admin\ActivityLogController;
use App\Http\Controllers\Admin\AnalyticsController;
use App\Http\Controllers\Admin\CashflowController;
use App\Http\Controllers\Admin\CashierController;
use App\Http\Controllers\Admin\Auth\LoginController;
use App\Http\Controllers\Admin\DashboardController;
use App\Http\Controllers\Admin\ExperienceController;
use App\Http\Controllers\Admin\OrderController;
use App\Http\Controllers\Admin\PermissionController;
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

    Route::middleware(['auth:admin', 'staff'])->group(function () {
        Route::get('/', DashboardController::class)->middleware('permission:dashboard.view')->name('dashboard');

        Route::middleware('permission:visitors.manage')->group(function () {
            Route::get('/visitors', [VisitorController::class, 'index'])->name('visitors.index');
            Route::get('/visitors/create', [VisitorController::class, 'create'])->name('visitors.create');
            Route::post('/visitors', [VisitorController::class, 'store'])->name('visitors.store');
            Route::get('/visitors/{visitor}', [VisitorController::class, 'show'])->name('visitors.show');
            Route::get('/visitors/{visitor}/edit', [VisitorController::class, 'edit'])->name('visitors.edit');
            Route::get('/visitors/{visitor}/faces/{pose}', [VisitorController::class, 'faceImage'])->name('visitors.face');
            Route::put('/visitors/{visitor}', [VisitorController::class, 'update'])->name('visitors.update');
            Route::post('/visitors/{visitor}/topup', [VisitorController::class, 'topUp'])->name('visitors.topup');
            Route::delete('/visitors/{visitor}', [VisitorController::class, 'destroy'])->name('visitors.destroy');
        });

        Route::middleware('permission:experiences.manage')->group(function () {
            Route::get('/experiences', [ExperienceController::class, 'index'])->name('experiences.index');
            Route::get('/experiences/{visitor}', [ExperienceController::class, 'show'])->name('experiences.show');
            Route::post('/experiences/{visitor}', [ExperienceController::class, 'store'])->name('experiences.store');
            Route::delete('/experiences/{visitor}/{experience}', [ExperienceController::class, 'destroy'])->name('experiences.destroy');
            Route::get('/experiences/{visitor}/{experience}/image', [ExperienceController::class, 'image'])->name('experiences.image');
            Route::get('/experiences/{visitor}/captures/{presence}', [ExperienceController::class, 'capture'])->name('experiences.capture');
        });

        Route::middleware('permission:rfid.manage')->group(function () {
            Route::get('/rfid/bind', [RfidBindController::class, 'create'])->name('rfid.bind');
            Route::post('/rfid/bind', [RfidBindController::class, 'store'])->name('rfid.bind.store');
            Route::post('/rfid/stock', [RfidBindController::class, 'stock'])->name('rfid.stock');
            Route::get('/rfid/scans', [RfidScanLogController::class, 'index'])->name('rfid.scans');
        });

        Route::middleware('permission:products.manage')->group(function () {
            Route::get('/products', [ProductController::class, 'index'])->name('products.index');
            Route::get('/products/create', [ProductController::class, 'create'])->name('products.create');
            Route::post('/products', [ProductController::class, 'store'])->name('products.store');
            Route::get('/products/{product}/edit', [ProductController::class, 'edit'])->name('products.edit');
            Route::put('/products/{product}', [ProductController::class, 'update'])->name('products.update');
            Route::delete('/products/{product}', [ProductController::class, 'destroy'])->name('products.destroy');
        });

        Route::middleware('permission:orders.manage')->group(function () {
            Route::get('/orders', [OrderController::class, 'index'])->name('orders.index');
            Route::get('/orders/{order}', [OrderController::class, 'show'])->name('orders.show');
            Route::put('/orders/{order}/status', [OrderController::class, 'updateStatus'])->name('orders.updateStatus');
        });

        Route::get('/analytics', [AnalyticsController::class, 'index'])->middleware('permission:analytics.view')->name('analytics');
        Route::put('/analytics/costs', [AnalyticsController::class, 'updateCosts'])->middleware('permission:finance.manage')->name('analytics.costs');

        Route::get('/cashflow', [CashflowController::class, 'index'])->middleware('permission:finance.manage')->name('cashflow');

        Route::get('/cashier', [CashierController::class, 'index'])->name('cashier');
        Route::post('/cashier/open', [CashierController::class, 'open'])->name('cashier.open');
        Route::post('/cashier/topup', [CashierController::class, 'topUp'])->name('cashier.topup');
        Route::post('/cashier/shifts/{shift}/close', [CashierController::class, 'close'])->name('cashier.close');

        Route::middleware('permission:staff.manage')->group(function () {
            Route::get('/staff', [StaffController::class, 'index'])->name('staff.index');
            Route::get('/staff/create', [StaffController::class, 'create'])->name('staff.create');
            Route::post('/staff', [StaffController::class, 'store'])->name('staff.store');
            Route::get('/staff/{staff}/edit', [StaffController::class, 'edit'])->name('staff.edit');
            Route::put('/staff/{staff}', [StaffController::class, 'update'])->name('staff.update');
            Route::delete('/staff/{staff}', [StaffController::class, 'destroy'])->name('staff.destroy');
        });

        Route::middleware('permission:permissions.manage')->group(function () {
            Route::get('/permissions', [PermissionController::class, 'edit'])->name('permissions.edit');
            Route::put('/permissions', [PermissionController::class, 'update'])->name('permissions.update');
        });

        Route::get('/activity', [ActivityLogController::class, 'index'])->middleware('permission:activity.view')->name('activity.index');
    });
});
