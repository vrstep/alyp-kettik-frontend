import base64
import httpx
from typing import Union

# URL бэкенда — меняйте на ngrok-адрес при каждом запуске
BACKEND_URL = "https://YOUR-NGROK-URL.ngrok-free.app"


async def recognize_products(image_input: Union[str, bytes]) -> dict:
    """Распознаёт товары на изображении.
    
    Args:
        image_input: Путь к файлу (str) или байты изображения (bytes)
    
    Returns:
        dict: Результат распознавания с товарами и итоговой суммой
    """
    if isinstance(image_input, str):
        with open(image_input, "rb") as f:
            img_b64 = base64.b64encode(f.read()).decode("utf-8")
    else:
        img_b64 = base64.b64encode(image_input).decode("utf-8")

    async with httpx.AsyncClient(timeout=60) as client:
        r = await client.post(
            f"{BACKEND_URL}/recognize",
            json={"image_base64": img_b64},
        )
        r.raise_for_status()
        return r.json()


async def checkout(items: list, total: float, card_number: str) -> dict:
    async with httpx.AsyncClient(timeout=30) as client:
        r = await client.post(
            f"{BACKEND_URL}/checkout",
            json={
                "items": items,
                "total": total,
                "card_number": card_number,
            },
        )
        r.raise_for_status()
        return r.json()