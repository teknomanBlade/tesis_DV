using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class CraftingScreen : MonoBehaviour, IScreen
{
    Button[] _buttons;
    public GameObject InventoryAndTrapDescriptions;
    public GameObject TrapProgressionSystem;
    public Scrollbar ScrollBarVertical;
    public Button closeScreen;
    public bool IsWorkbenchScreenOpened { get; set; }
    //public Button BTNPage1;
    //public Button BTNPage2;

    private void Awake()
    {
        Cursor.lockState = CursorLockMode.Confined;
        /*if (InventoryAndTrapDescriptions.activeSelf)
        {
            BTNPage1.interactable = false;
        }*/
        /*_buttons = GetComponentsInChildren<Button>();

        foreach(var button in _buttons)
        {
            button.interactable = false;
        }*/
    }

    void Start()
    {
        this.gameObject.SetActive(false);
    }

    

    void Update()
    {
        if (Input.mouseScrollDelta.y < 0 || Input.GetKeyDown(KeyCode.DownArrow))
        {
            ScrollBarVertical.value = Mathf.Clamp(ScrollBarVertical.value - 0.1f,0.3f,1f);
        }
        else if (Input.mouseScrollDelta.y > 0 || Input.GetKeyDown(KeyCode.UpArrow))
        {
            ScrollBarVertical.value = Mathf.Clamp(ScrollBarVertical.value + 0.1f, 0.3f, 1f);
        }
        /*if (Input.GetKeyDown(KeyCode.Alpha1))
        {
            BTN_PageOne();
        }
        if (Input.GetKeyDown(KeyCode.Alpha2))
        {
            BTN_PageTwo();
        }*/
    }
    public void BTN_Back()
    {
        ScreenManager.Instance.Pop();
    }

    public void CloseScreen()
    {
        Debug.Log("HACE CLICK?");
        IsWorkbenchScreenOpened = false;
        gameObject.SetActive(false);
        Cursor.lockState = CursorLockMode.Locked;
    }

    public void BTN_PageOne()
    {
        IsWorkbenchScreenOpened = false;
        //Cursor.lockState = CursorLockMode.Confined;
        TrapProgressionSystem.SetActive(false);
        InventoryAndTrapDescriptions.SetActive(true);
        //BTNPage1.interactable = false;
        //BTNPage2.interactable = true;
    }

    public void BTN_PageTwo()
    {
        Cursor.lockState = CursorLockMode.Confined;
        IsWorkbenchScreenOpened = true;
        TrapProgressionSystem.SetActive(true);
        InventoryAndTrapDescriptions.SetActive(false);
        //BTNPage1.interactable = true;
        //BTNPage2.interactable = false;
    }

    public void Activate()
    {
        /*foreach(var button in _buttons)
        {
            button.interactable = true;
        }*/
    }

    public void Deactivate()
    {
        /*foreach(var button in _buttons)
        {
            button.interactable = false;
        }*/
    }

    public string Free()
    {
        Destroy(gameObject);
        return " ";
    }
}
