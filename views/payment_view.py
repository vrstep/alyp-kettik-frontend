import flet as ft
from services.api_client import checkout


def payment_view(page: ft.Page, items: list, total: float, on_success, on_back) -> ft.View:
    """Экран 3: Оплата через Forte симулятор."""

    card_field = ft.TextField(
        label="Номер карты",
        hint_text="4400 0000 0000 0001",
        keyboard_type=ft.KeyboardType.NUMBER,
        max_length=19,
        prefix_icon=ft.Icons.CREDIT_CARD,
        border_radius=12,
    )

    status_text  = ft.Text("", color=ft.Colors.RED_600, text_align=ft.TextAlign.CENTER)
    loading_ring = ft.ProgressRing(visible=False, width=40, height=40)
    pay_btn      = ft.Button(
        f"Оплатить {total:,.0f} ₸",
        bgcolor=ft.Colors.GREEN_600,
        color=ft.Colors.WHITE,
        height=52,
        style=ft.ButtonStyle(shape=ft.RoundedRectangleBorder(radius=12)),
    )

    async def on_pay_click(e):
        card = card_field.value.replace(" ", "")
        if len(card) < 12:
            status_text.value = "Введите корректный номер карты"
            page.update()
            return

        pay_btn.disabled = True
        loading_ring.visible = True
        status_text.value = ""
        page.update()

        try:
            result = await checkout(items, total, card)
            on_success(result)
        except Exception as ex:
            status_text.value = f"Ошибка оплаты: {ex}"
            pay_btn.disabled = False
        finally:
            loading_ring.visible = False
            page.update()

    pay_btn.on_click = on_pay_click

    return ft.View(
        "/payment",
        [
            ft.AppBar(
                title=ft.Text("Оплата"),
                leading=ft.IconButton(ft.Icons.ARROW_BACK, on_click=lambda _: on_back()),
                bgcolor=ft.Colors.GREEN_700,
                color=ft.Colors.WHITE,
            ),
            ft.Container(
                content=ft.Column(
                    [
                        ft.Icon(ft.Icons.PAYMENT, size=64, color=ft.Colors.GREEN_700),
                        ft.Text("Введите данные карты", size=18, weight=ft.FontWeight.BOLD),
                        ft.Container(
                            content=ft.Column([
                                ft.Text(f"Товаров: {len(items)} шт.", color=ft.Colors.GREY_700),
                                ft.Text(f"Сумма: {total:,.0f} ₸", size=16, weight=ft.FontWeight.BOLD),
                            ]),
                            bgcolor=ft.Colors.GREY_100,
                            border_radius=8,
                            padding=12,
                            width=float("inf"),
                        ),
                        card_field,
                        status_text,
                        loading_ring,
                        pay_btn,
                    ],
                    spacing=16,
                    horizontal_alignment=ft.CrossAxisAlignment.STRETCH,
                ),
                padding=24,
                expand=True,
            ),
        ],
    )