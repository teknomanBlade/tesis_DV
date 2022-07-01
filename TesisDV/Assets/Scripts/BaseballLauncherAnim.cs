using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BaseballLauncherAnim : MonoBehaviour
{
    public GameObject trapPrefab;
    Animator myAnimator;
    private GameObject parent; 
    void Start()
    {
        myAnimator = GetComponent<Animator>();
        parent = GameObject.Find("MainGame");
    }

    public void FinishAnim()
    {
        GameObject aux = Instantiate(trapPrefab, transform.position, transform.rotation, parent.transform);
        Destroy(aux.GetComponent<InventoryItem>());
        Destroy(gameObject);
    }
}
