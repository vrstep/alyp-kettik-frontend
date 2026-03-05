import flet as ft
from views.camera_view import camera_view
from views.cart_view import cart_view
from views.payment_view import payment_view


def main(page: ft.Page):
    page.title = "Cashierless Store"
    page.theme_mode = ft.ThemeMode.LIGHT
    page.theme = ft.Theme(color_scheme_seed=ft.Colors.BLUE)
    page.window.status_bar_color = ft.Colors.BLUE_700
    page.bgcolor = ft.Colors.WHITE

    # ── Общее состояние ────────────────────────────────────────────────────────
    state = {
        "recognition": None,
        "items": [],
        "total": 0.0,
        "order_id": None,
    }

    # ── Функции навигации ─────────────────────────────────────────────────────
    def show_camera():
        page.clean()
        page.add(camera_view(page, on_recognized=show_cart))
        page.update()

    def show_cart(recognition_result: dict):
        state["recognition"] = recognition_result
        page.clean()
        page.add(
            cart_view(
                page,
                recognition_result=recognition_result,
                on_pay=show_payment,
                on_back=show_camera,
            )
        )
        page.update()

    def show_payment(items: list, total: float):
        state["items"] = items
        state["total"] = total
        page.clean()
        page.add(
            payment_view(
                page,
                items=items,
                total=total,
                on_success=show_success,
                on_back=lambda: show_cart(state["recognition"]),
            )
        )
        page.update()

    def show_success(result: dict):
        state["order_id"] = result.get("order_id", "—")
        order_id = state.get("order_id", "—")
        page.clean()
        page.add(
            ft.View(
                "/success",
                [
                    ft.AppBar(title=ft.Text("Оплата прошла"), bgcolor=ft.Colors.GREEN_700, color=ft.Colors.WHITE),
                    ft.Container(
                        content=ft.Column(
                            [
                                ft.Icon(ft.Icons.CHECK_CIRCLE, size=96, color=ft.Colors.GREEN_600),
                                ft.Text("Оплата успешна!", size=24, weight=ft.FontWeight.BOLD),
                                ft.Text(f"Заказ: {order_id}", color=ft.Colors.GREY_700),
                                ft.Text(
                                    f"Сумма: {state['total']:,.0f} ₸",
                                    size=18,
                                    weight=ft.FontWeight.BOLD,
                                    color=ft.Colors.GREEN_700,
                                ),
                                ft.Button(
                                    "🏠  На главную",
                                    bgcolor=ft.Colors.BLUE_700,
                                    color=ft.Colors.WHITE,
                                    height=52,
                                    style=ft.ButtonStyle(shape=ft.RoundedRectangleBorder(radius=12)),
                                    on_click=lambda _: show_camera(),
                                ),
                            ],
                            horizontal_alignment=ft.CrossAxisAlignment.CENTER,
                            spacing=20,
                        ),
                        padding=32,
                        expand=True,
                    ),
                ],
            )
        )
        page.update()

    # ── Старт ─────────────────────────────────────────────────────────────────
    show_camera()


ft.run(main)