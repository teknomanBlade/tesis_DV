using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BaseballLauncherDestroyAnim : MonoBehaviour
{
    [SerializeField]
    private GameObject particles;
    void Start()
    {
        StartCoroutine(DestroyThisTrapAnim());
        Instantiate(particles, transform.position, transform.rotation);
    }

    IEnumerator DestroyThisTrapAnim()
    {
        yield return new WaitForSeconds(2);

        Destroy(this.gameObject);
        

        
    }
}
