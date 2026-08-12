@if ($paginator->hasPages())
    <nav>
        @if ($paginator->onFirstPage())
            <span>‹ Prev</span>
        @else
            <a href="{{ $paginator->previousPageUrl() }}">‹ Prev</a>
        @endif

        @foreach ($paginator->getUrlRange(max(1, $paginator->currentPage() - 2), min($paginator->lastPage(), $paginator->currentPage() + 2)) as $page => $url)
            @if ($page == $paginator->currentPage())
                <span class="active"><span>{{ $page }}</span></span>
            @else
                <a href="{{ $url }}">{{ $page }}</a>
            @endif
        @endforeach

        @if ($paginator->hasMorePages())
            <a href="{{ $paginator->nextPageUrl() }}">Next ›</a>
        @else
            <span>Next ›</span>
        @endif
    </nav>
@endif
