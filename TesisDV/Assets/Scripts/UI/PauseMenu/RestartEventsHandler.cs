using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

public class RestartEventsHandler : MonoBehaviour,IPointerDownHandler,IPointerEnterHandler, IPointerUpHandler, IPointerExitHandler
{
    private RectTransform btnRestartRect;
    // Start is called before the first frame update
    void Start()
    {
        btnRestartRect = GetComponent<RectTransform>();
    }

    // Update is called once per frame
    void Update()
    {

    }

    public void OnPointerDown(PointerEventData eventData)
    {
        Debug.Log("PRESSED BUTTON RESTART: " + eventData.pointerPress?.name);
        if (eventData.pointerPress == null) return;
        eventData.pointerPress.GetComponent<RectTransform>().anchoredPosition = new Vector2(-380f, 0f);
        eventData.pointerPress.GetComponent<RectTransform>().sizeDelta = new Vector2(188f, 50f);
    }

    public void OnPointerEnter(PointerEventData eventData)
    {
        Debug.Log("HIGHLIGHTED BUTTON RESTART: " + eventData.pointerEnter?.name);
        eventData.pointerEnter.GetComponent<RectTransform>().anchoredPosition = new Vector2(-380f, 0f);
        eventData.pointerEnter.GetComponent<RectTransform>().sizeDelta = new Vector2(188f, 50f);
    }

    public void OnPointerUp(PointerEventData eventData)
    {
        btnRestartRect.anchoredPosition = new Vector2(-315f, -12f);
        btnRestartRect.sizeDelta = new Vector2(160f, 30f);
    }

    public void OnPointerExit(PointerEventData eventData)
    {
        btnRestartRect.anchoredPosition = new Vector2(-315f, -12f);
        btnRestartRect.sizeDelta = new Vector2(160f, 30f);
    }
}
