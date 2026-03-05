import flet as ft


def main(page: ft.Page):
    page.title = "Test"
    page.bgcolor = ft.Colors.WHITE

    page.add(
        ft.AppBar(title=ft.Text("Test App"), bgcolor=ft.Colors.BLUE_700),
        ft.Container(
            content=ft.Column(
                [
                    ft.Icon(ft.Icons.CAMERA_ALT, size=64, color=ft.Colors.BLUE_700),
                    ft.Text("Test Screen", size=24, weight=ft.FontWeight.BOLD),
                    ft.Button("Click me", on_click=lambda _: print("Clicked")),
                ],
                horizontal_alignment=ft.CrossAxisAlignment.CENTER,
                spacing=16,
            ),
            padding=24,
            expand=True,
        ),
    )


ft.run(main)
