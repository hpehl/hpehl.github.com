var // const
    FIXED = "fixed",

    _window = $(window),
    _body = $('body'),
    _bodyHtml = $('body, html'),
    $header = $('header')
    $menu = $('header #menu'),
    $menuHeight = $menu.height(),
    $menuOffsetTop = $header.height() - $menu.height(),
    $backToTop = $('#backToTop'),

_window.bind('scroll.global', _resizeMenu);

function _resizeMenu()
{
    var _navIsFix = $menu.hasClass(FIXED),
        _scrollTop = _window.scrollTop() || _body.scrollTop || _bodyHtml.scrollTop;

    // Header - menu
    if ((_scrollTop >= $menuOffsetTop && !_navIsFix) || (_scrollTop<$menuOffsetTop && _navIsFix)) {
        _navIsFix ? $menu.removeClass(FIXED) : $menu.addClass(FIXED);
    }
}