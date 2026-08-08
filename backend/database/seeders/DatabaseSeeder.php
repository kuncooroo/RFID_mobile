<?php

namespace Database\Seeders;

use App\Models\Category;
use App\Models\Member;
use App\Models\Product;
use App\Models\ProductColor;
use App\Models\ProductImage;
use App\Models\ProductSize;
use App\Models\Promotion;
use App\Models\RfidMember;
use App\Models\Store;
use App\Models\User;
use App\Models\UserSetting;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        if (! app()->environment(['local', 'testing'])) {
            $this->command?->warn('DatabaseSeeder skipped outside local/testing.');

            return;
        }

        $user = User::query()->create([
            'name' => 'Demo User',
            'email' => 'demo@kutuku.test',
            'phone' => '+10000000001',
            'password' => Hash::make('password'),
            'onboarding_completed_at' => now(),
        ]);

        Member::query()->create([
            'user_id' => $user->id,
            'display_name' => 'Demo User',
            'membership_tier' => 'gold',
            'points' => 1200,
        ]);

        UserSetting::query()->create([
            'user_id' => $user->id,
        ]);

        $user->cart()->create(['currency' => 'USD']);

        RfidMember::query()->create([
            'user_id' => $user->id,
            'member_code' => 'MEM-1001',
            'rfid_uid' => 'RFID-DEMO-001',
            'is_active' => true,
        ]);

        $store = Store::query()->create([
            'name' => 'Kutuku Official',
            'slug' => 'kutuku-official',
            'description' => 'Official Kutuku store',
            'is_verified' => true,
            'rating_avg' => 4.8,
            'location' => 'Jakarta',
            'logo_path' => 'https://picsum.photos/seed/store/200',
            'banner_path' => 'https://picsum.photos/seed/banner/800/300',
        ]);

        $categories = collect([
            ['name' => 'Fashion', 'slug' => 'fashion'],
            ['name' => 'Electronics', 'slug' => 'electronics'],
            ['name' => 'Beauty', 'slug' => 'beauty'],
            ['name' => 'Home', 'slug' => 'home'],
        ])->map(fn (array $c, int $i) => Category::query()->create([
            ...$c,
            'sort_order' => $i + 1,
            'image_path' => 'https://picsum.photos/seed/'.$c['slug'].'/200',
        ]));

        $colors = collect([
            ['name' => 'Black', 'hex' => '#111111'],
            ['name' => 'White', 'hex' => '#FFFFFF'],
            ['name' => 'Purple', 'hex' => '#514EB7'],
        ])->map(fn (array $c) => ProductColor::query()->create($c));

        $sizes = collect(['S', 'M', 'L', 'XL'])
            ->map(fn (string $label) => ProductSize::query()->create(['label' => $label]));

        foreach (range(1, 12) as $i) {
            $product = Product::query()->create([
                'store_id' => $store->id,
                'category_id' => $categories[$i % $categories->count()]->id,
                'name' => "Demo Product {$i}",
                'slug' => 'demo-product-'.$i.'-'.Str::random(4),
                'brand' => 'Kutuku',
                'description' => 'Sample product seeded for API development.',
                'price' => 49.99 + $i,
                'discount_price' => $i % 2 === 0 ? 39.99 + $i : null,
                'currency' => 'USD',
                'stock' => 50,
                'rating_avg' => 4.0 + ($i % 10) / 10,
                'reviews_count' => $i,
                'is_active' => true,
            ]);

            ProductImage::query()->create([
                'product_id' => $product->id,
                'path' => 'https://picsum.photos/seed/p'.$i.'/600',
                'sort_order' => 0,
                'is_primary' => true,
            ]);

            $product->colors()->attach($colors->random(2)->pluck('id'));
            $product->sizes()->attach($sizes->pluck('id'));
        }

        Promotion::query()->create([
            'title' => 'Summer Sale',
            'subtitle' => 'Up to 40% off',
            'image_path' => 'https://picsum.photos/seed/promo/800/400',
            'store_id' => $store->id,
            'discount_percent' => 40,
            'is_active' => true,
            'sort_order' => 1,
            'starts_at' => now()->subDay(),
            'ends_at' => now()->addMonth(),
        ]);
    }
}
