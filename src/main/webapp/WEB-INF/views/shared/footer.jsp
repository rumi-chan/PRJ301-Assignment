<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
    </main>
    <footer class="mt-20 border-t border-white/10 bg-black/20">
        <div class="mx-auto grid max-w-7xl gap-8 px-4 py-10 sm:px-6 md:grid-cols-3 lg:px-8">
            <div>
                <p class="text-lg font-black">Cine<span class="text-rose-500">Book</span></p>
                <p class="mt-2 max-w-sm text-sm leading-6 text-zinc-500">Great stories deserve the right screen—and the right seat.</p>
            </div>
            <div>
                <p class="text-xs font-bold uppercase tracking-[.2em] text-zinc-500">Explore</p>
                <div class="mt-3 flex flex-col gap-2 text-sm text-zinc-400">
                    <a class="hover:text-white" href="<c:url value='/movies'/>">Movies</a>
                    <a class="hover:text-white" href="<c:url value='/cinemas'/>">Cinemas</a>
                    <a class="hover:text-white" href="<c:url value='/profile/bookings'/>">Booking history</a>
                </div>
            </div>
            <div class="md:text-right">
                <p class="text-xs font-bold uppercase tracking-[.2em] text-zinc-500">Student project</p>
                <p class="mt-3 text-sm text-zinc-500">Java Servlet · JSP · SQL Server</p>
                <p class="mt-1 text-sm text-zinc-600">Times shown in Asia/Ho_Chi_Minh</p>
            </div>
        </div>
        <div class="border-t border-white/5 py-4 text-center text-xs text-zinc-600">© 2026 CineBook. Demo cinema booking experience.</div>
    </footer>
</div>
<script src="<c:url value='/assets/js/app.js'/>"></script>
<c:if test="${param.bookingScripts == 'true'}"><script src="<c:url value='/assets/js/booking.js'/>"></script></c:if>
</body>
</html>
