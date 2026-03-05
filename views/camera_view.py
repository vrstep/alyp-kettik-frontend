import base64
import flet as ft
import flet_camera as fc
from services.api_client import recognize_products

def camera_view(page: ft.Page, on_recognized) -> ft.View:
    """Screen 1: Camera — take a photo or upload from device."""

    status_text = ft.Text("Loading camera...", size=16, text_align=ft.TextAlign.CENTER)
    loading_ring = ft.ProgressRing(visible=True, width=48, height=48)
    
    scan_btn = ft.Button(
        "📷 Take Photo",
        style=ft.ButtonStyle(shape=ft.RoundedRectangleBorder(radius=12)),
        height=52,
        disabled=True,
    )

    upload_btn = ft.Button(
        "📁 Upload File",
        style=ft.ButtonStyle(shape=ft.RoundedRectangleBorder(radius=12)),
        height=52,
    )

    # ── Camera Setup ─────────────────────────────────────────────────────────
    camera = fc.Camera(
        expand=True,
        preview_enabled=True,
    )

    captured_image: list[bytes] = []  # mutable ref

    # ── New File Picker Logic ────────────────────────────────────────────────
    async def on_upload_click(e):
        # Await the file picker directly
        files = await ft.FilePicker().pick_files(
            allow_multiple=False, 
            file_type=ft.FilePickerFileType.IMAGE
        )
        
        if files and len(files) > 0:
            file_path = files[0].path
            try:
                with open(file_path, "rb") as f:
                    image_bytes = f.read()
                
                captured_image.clear()
                captured_image.append(image_bytes)
                
                # Assign base64 to 'src' directly instead of 'src_base64'
                preview_img.src = base64.b64encode(image_bytes).decode("utf-8")
                preview_img.visible = True
                camera.visible = False

                scan_btn.text = "🔍 Recognize Products"
                scan_btn.disabled = False
                status_text.value = "Image uploaded — click Recognize"
                
                page.update()
            except Exception as ex:
                status_text.value = f"❌ File read error: {ex}"
                page.update()

    upload_btn.on_click = on_upload_click

    # ── Button Handlers ───────────────────────────────────────────────────────
    async def on_btn_click(e):
        # 1. Take Photo or Process Selected
        if not captured_image:
            status_text.value = "Taking photo..."
            scan_btn.disabled = True
            page.update()

            try:
                # Capture the photo directly as bytes
                image_bytes = await camera.take_picture()
                captured_image.append(image_bytes)

                # Assign base64 to 'src' directly instead of 'src_base64'
                preview_img.src = base64.b64encode(image_bytes).decode("utf-8")
                preview_img.visible = True
                camera.visible = False

                scan_btn.text = "🔍 Recognize Products"
                scan_btn.disabled = False
                status_text.value = "Photo ready — click Recognize"
                page.update()
            except Exception as ex:
                status_text.value = f"❌ Error: {ex}"
                scan_btn.disabled = False
                page.update()
            return

        # 2. Recognize Products
        scan_btn.disabled = True
        loading_ring.visible = True
        status_text.value = "⏳ Recognizing products via AI..."
        page.update()

        try:
            # Your API client handles the bytes natively
            result = await recognize_products(captured_image[0])
            on_recognized(result)  # Move to the cart screen
        except Exception as ex:
            status_text.value = f"❌ Error: {ex}"
        finally:
            scan_btn.disabled = False
            loading_ring.visible = False
            page.update()

    scan_btn.on_click = on_btn_click

    # ── Retake/Reset ─────────────────────────────────────────────────────────
    def on_retake(e):
        captured_image.clear()
        preview_img.visible = False
        camera.visible = True
        scan_btn.text = "📷 Take Photo"
        scan_btn.disabled = False
        status_text.value = "Take a photo of the items on the table"
        page.update()

    retake_btn = ft.Button(
        "Retake",
        visible=False,
        style=ft.ButtonStyle(
            bgcolor=ft.Colors.TRANSPARENT,
            padding=ft.Padding.symmetric(horizontal=16, vertical=8),
        ),
        on_click=on_retake,
    )

    # ── Image Preview ─────────────────────────────────────────────────────────
    preview_img = ft.Image(
        src="",  # Replaced src_base64 with src
        visible=False,
        border_radius=12,
        height=300,
        fit=ft.BoxFit.CONTAIN,  
    )

    # ── Initialize Camera ─────────────────────────────────────────────────────
    async def init_camera():
        try:
            cameras = await camera.get_available_cameras()
            if cameras:
                await camera.initialize(
                    description=cameras[0],
                    resolution_preset=fc.ResolutionPreset.HIGH,
                    image_format_group=fc.ImageFormatGroup.JPEG,
                )
                scan_btn.disabled = False
                status_text.value = "Take a photo of the items on the table"
            else:
                status_text.value = "Camera not found. You can still upload."
        except Exception as ex:
            status_text.value = f"Camera Error: {ex}. Try uploading a file."
        finally:
            loading_ring.visible = False
            page.update()

    page.run_task(init_camera)

    return ft.View(
        "/camera",
        [
            ft.AppBar(title=ft.Text("Cashierless Store"), center_title=True, bgcolor=ft.Colors.BLUE_700),
            ft.Container(
                content=ft.Column(
                    [
                        ft.Icon(ft.Icons.CAMERA_ALT, size=64, color=ft.Colors.BLUE_700),
                        status_text,
                        ft.Container(
                            content=camera,
                            width=float("inf"),
                            height=300,
                            bgcolor=ft.Colors.BLACK,
                            border_radius=12,
                        ),
                        preview_img,
                        loading_ring,
                        ft.Row(
                            [scan_btn, upload_btn],
                            alignment=ft.MainAxisAlignment.CENTER,
                        ),
                        retake_btn,
                    ],
                    horizontal_alignment=ft.CrossAxisAlignment.CENTER,
                    spacing=16,
                ),
                padding=24,
                expand=True,
            ),
        ],
    )
