using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class YouLoseScreen : MonoBehaviour, IScreen
{
    public void Activate()
    {

    }

    public void Deactivate()
    {

    }

    public string Free()
    {
        Destroy(gameObject);
        return "YouLose";
    }

    public void ActiveScreen()
    {
        gameObject.SetActive(true);
    }

    // Start is called before the first frame update
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.R))
        {
            SceneManager.LoadScene("MainFloor_Upgrade");
        }
    }
}
