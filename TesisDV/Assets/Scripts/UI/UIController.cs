using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UIController : MonoBehaviour
{
    void Update()
    {
        if(Input.GetKeyDown(KeyCode.Tab))
            {
                var screenCrafting = Instantiate(Resources.Load<CraftingScreen>("CraftingCanvas"));
                ScreenManager.Instance.Push(screenCrafting);
            }
    }
}
