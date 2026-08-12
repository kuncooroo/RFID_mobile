@extends('admin.layouts.app')

@section('title', 'Photo Gallery')
@section('heading', 'Wahana photo gallery')
@section('subheading', 'Face captures from RFID verifications (view only).')

@section('content')
<div class="gallery">
    @forelse($photos as $photo)
        <article class="gallery-card">
            <a href="{{ route('admin.gallery.show', $photo) }}" target="_blank" rel="noopener">
                <img src="{{ route('admin.gallery.show', $photo) }}" alt="Capture #{{ $photo->id }}">
            </a>
            <div class="meta">
                <strong>{{ $photo->user?->name ?? 'Unknown visitor' }}</strong>
                <div class="muted">{{ $photo->rfidMember?->rfid_uid ?? '—' }}</div>
                <div class="muted">{{ $photo->created_at?->format('Y-m-d H:i') }}</div>
            </div>
        </article>
    @empty
        <div class="panel full">No captured photos yet.</div>
    @endforelse
</div>
<div class="pagination">{{ $photos->links('admin.partials.pagination') }}</div>
@endsection
