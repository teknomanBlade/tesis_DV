using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Gray : MonoBehaviour
{
    [SerializeField]
    private GameObject _player;
    public float distanceToPlayer;
    public float threshold = 10f;
    public bool pursue;

    private void Update()
    {
        distanceToPlayer = Vector3.Distance(_player.transform.position, transform.position);
        if (IsInSight()) pursue = true;
        else pursue = false;

        if (pursue) Move();
    }

    public void Move()
    {

    }

    private bool IsInSight()
    {
        if (Vector3.Distance(_player.transform.position, transform.position) > threshold) return false;
        return true;
    }

    private void OnDrawGizmos()
    {
        Gizmos.DrawWireSphere(transform.position, threshold);
    }
}
