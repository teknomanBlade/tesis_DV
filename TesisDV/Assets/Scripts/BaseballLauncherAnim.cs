using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BaseballLauncherAnim : MonoBehaviour
{
    public GameObject trapPrefab;
    Animator myAnimator;
    void Start()
    {
        myAnimator = GetComponent<Animator>();
        
    }

    public void FinishAnim()
    {
        GameObject aux = Instantiate(trapPrefab, transform.position, transform.rotation);
        Destroy(aux.GetComponent<InventoryItem>());
        Destroy(gameObject);
    }
}
