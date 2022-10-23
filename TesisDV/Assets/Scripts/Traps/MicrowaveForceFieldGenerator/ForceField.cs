using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ForceField : MonoBehaviour
{
    public float Health;
    // Start is called before the first frame update
    void Awake()
    {
        Health = 100f;
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    private void OnTriggerEnter(Collider other)
    {
        var gray = other.gameObject.GetComponent<GrayModel>();
        if (gray != null)
        {
            gray._movingSpeed = 0f;
        }
        var grayMelee = other.gameObject.GetComponent<TallGrayModel>();
        if (grayMelee != null)
        {
            grayMelee._movingSpeed = 0f;
            grayMelee._fsm.ChangeState(EnemyStatesEnum.AttackTrapState);
        }
    }
}
