using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class UIController : MonoBehaviour
{
    void Update()
    {
        if(Input.GetKeyDown(KeyCode.Tab))
            {
                var screenCrafting = Instantiate(Resources.Load<CraftingScreen>("CraftingCanvas"));
                ScreenManager.Instance.Push(screenCrafting);
            }

        if(Input.GetKeyDown(KeyCode.R))
            {
                SceneManager.LoadScene("MainFloor_Upgrade");
            }
    }
}
