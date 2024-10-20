using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GrayAttackRing : MonoBehaviour
{
    public GrayModel _myOwner;
    public int _damageAmount;

    private void Awake()
    {
        _myOwner = transform.GetComponentInParent<GrayModel>();
    }

    public void EnableBoxCollider()
    {
        Invoke("ActiveCollider", 0.8f);
    }

    public void ActiveCollider()
    {
        GetComponent<BoxCollider>().enabled = true;
    }

    void OnTriggerEnter(Collider other)
    {
        var player = other.GetComponent<Player>();

        if (player)
        {
            //Debug.Log("ENTRA EN TRIGGER DAMAGE?");
            other.GetComponent<Player>().Damage(_damageAmount);
            GetComponent<BoxCollider>().enabled = false;
        }
    }
}
