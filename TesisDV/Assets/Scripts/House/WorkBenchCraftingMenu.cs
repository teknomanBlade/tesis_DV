using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WorkBenchCraftingMenu : MonoBehaviour, IInteractable
{
    private CraftingScreen _craftingScreen;
    // Start is called before the first frame update
    void Awake()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public void OpenCraftingPurchaseMenu()
    {
        _craftingScreen.BTN_PageTwo();
    }

    public WorkBenchCraftingMenu SetCraftingMenu(CraftingScreen craftingScreen)
    {
        _craftingScreen = craftingScreen;
        return this;
    }

    public void Interact()
    {
        Debug.Log("ENTRA EN WORKBENCH MENU??");
    }
}
