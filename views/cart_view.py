import flet as ft


def cart_view(page: ft.Page, recognition_result: dict, on_pay, on_back) -> ft.View:
    """Экран 2: Корзина с распознанными товарами."""

    items       = recognition_result.get("recognized_items", [])
    unrecognized = recognition_result.get("unrecognized", [])
    total       = recognition_result.get("total", 0)

    def item_tile(item: dict) -> ft.Card:
        return ft.Card(
            content=ft.Container(
                content=ft.Row(
                    [
                        ft.Column(
                            [
                                ft.Text(item["name"], weight=ft.FontWeight.BOLD, size=15),
                                ft.Text(
                                    item.get("category", ""),
                                    color=ft.Colors.GREY_600,
                                    size=12,
                                ),
                            ],
                            expand=True,
                            spacing=2,
                        ),
                        ft.Column(
                            [
                                ft.Text(
                                    f"{item['price']:,.0f} ₸",
                                    weight=ft.FontWeight.BOLD,
                                    color=ft.Colors.BLUE_700,
                                    size=15,
                                ),
                                ft.Text(
                                    f"x{item.get('quantity', 1)}",
                                    color=ft.Colors.GREY_600,
                                    size=12,
                                ),
                            ],
                            horizontal_alignment=ft.CrossAxisAlignment.END,
                            spacing=2,
                        ),
                    ],
                    alignment=ft.MainAxisAlignment.SPACE_BETWEEN,
                ),
                padding=ft.Padding.symmetric(horizontal=16, vertical=12),
            ),
            elevation=1,
        )

    item_list = ft.Column(
        [item_tile(i) for i in items] if items else [
            ft.Text("Товары не распознаны", color=ft.Colors.GREY_600)
        ],
        spacing=8,
        scroll=ft.ScrollMode.AUTO,
        expand=True,
    )

    # Нераспознанные товары
    unrecognized_widget = ft.Container(visible=False)
    if unrecognized:
        unrecognized_widget = ft.Container(
            content=ft.Column([
                ft.Text("⚠️ Не найдено в базе:", color=ft.Colors.ORANGE_700, weight=ft.FontWeight.BOLD),
                *[ft.Text(f"• {u}", color=ft.Colors.ORANGE_600) for u in unrecognized],
            ]),
            bgcolor=ft.Colors.ORANGE_50,
            border_radius=8,
            padding=12,
            visible=True,
        )

    total_row = ft.Container(
        content=ft.Row(
            [
                ft.Text("Итого:", size=20, weight=ft.FontWeight.BOLD),
                ft.Text(f"{total:,.0f} ₸", size=20, weight=ft.FontWeight.BOLD, color=ft.Colors.BLUE_700),
            ],
            alignment=ft.MainAxisAlignment.SPACE_BETWEEN,
        ),
        bgcolor=ft.Colors.BLUE_50,
        border_radius=12,
        padding=ft.Padding.symmetric(horizontal=16, vertical=12),
    )

    pay_btn = ft.Button(
        f"💳  Оплатить {total:,.0f} ₸",
        bgcolor=ft.Colors.BLUE_700,
        color=ft.Colors.WHITE,
        height=52,
        style=ft.ButtonStyle(shape=ft.RoundedRectangleBorder(radius=12)),
        on_click=lambda _: on_pay(items, total),
        disabled=len(items) == 0,
    )

    return ft.View(
        "/cart",
        [
            ft.AppBar(
                title=ft.Text("Корзина"),
                leading=ft.IconButton(ft.Icons.ARROW_BACK, on_click=lambda _: on_back()),
                bgcolor=ft.Colors.BLUE_700,
                color=ft.Colors.WHITE,
            ),
            ft.Container(
                content=ft.Column(
                    [
                        ft.Text(
                            f"Найдено товаров: {len(items)}",
                            color=ft.Colors.GREY_700,
                            size=13,
                        ),
                        unrecognized_widget,
                        item_list,
                        total_row,
                        pay_btn,
                    ],
                    spacing=12,
                    expand=True,
                ),
                padding=16,
                expand=True,
            ),
        ],
    )