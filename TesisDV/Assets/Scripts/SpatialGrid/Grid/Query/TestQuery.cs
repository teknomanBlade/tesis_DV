using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Linq;

public class TestQuery : MonoBehaviour
{
    [SerializeField] SquareQuery query;
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Space))
        {
            var result = query.Query().Select(x => x as Gray).Where(x => x != null);

            var result2 = query.Query().Select(x => x as Gray).Where(x => x != null).Where(enemy => enemy.hp < 3);

            foreach (var item in result)
            {
                Debug.Log(item.name);
            }
        }
        
    }
}
