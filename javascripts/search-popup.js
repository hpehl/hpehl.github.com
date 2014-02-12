/**
 * modalEffects.js v1.0.0 (with quick & dirty search mixins)
 * http://www.codrops.com
 * 
 * Licensed under the MIT license.
 * http://www.opensource.org/licenses/mit-license.php
 *
 * Copyright 2013, Codrops
 * http://www.codrops.com
 */
var ModalEffects = (function () {
    function init() {

        var overlay = document.querySelector('.md-overlay');
        [].slice.call(document.querySelectorAll('.md-trigger')).forEach(function (el, i) {

            var modal = document.querySelector('#' + el.getAttribute('data-modal')),
				close = modal.querySelector( '.md-close' );

            function closePopup() {
                classie.remove(modal, 'md-show');
                classie.remove(document.body, 'disable-scrolling');
                $(document).off('keyup', escHandler);
            }

            function escHandler(evt) {
                if (evt.keyCode == 27) {
                    closePopup();
                }
            }

            function showPopup() {
                classie.add(document.body, 'disable-scrolling');
                $('#search-query').val("");
                $('.search-entries').text("");
                var height = (window.innerHeight - 140);
                $('.md-content').height(height);
                var searchEntriesHeight = height - $('.query').height() - $('.footer').height();
                $('.search-entries').height(searchEntriesHeight);
                classie.add(modal, 'md-show');
                overlay.removeEventListener('click', closePopup);
                overlay.addEventListener('click', closePopup);
                $(document).on('keyup', escHandler);
                $.delay(function () {
                    // $('#search-query').focus() does not work
                    jQuery('#search-query').focus();                    
                }, 333);
            }

            el.addEventListener('click', showPopup);

            close.addEventListener('click', function (ev) {
                ev.stopPropagation();
                closePopup();
            });

            Mousetrap.bind('mod+.', showPopup);
        });
    }
    init();
})();