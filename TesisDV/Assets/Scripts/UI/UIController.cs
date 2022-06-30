using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class UIController : MonoBehaviour
{
    private void Awake()
    {
        
    }

    void Update()
    {
        if (GameVars.Values.LevelManager.YouWin.activeSelf || GameVars.Values.LevelManager.YouLose.activeSelf)
        {
            if (Input.GetKeyDown(KeyCode.M))
            {
                SceneManager.LoadScene(0);
            }

            if (Input.GetKeyDown(KeyCode.R))
            {
                SceneManager.LoadScene(1);
            }
        }
    }
}
